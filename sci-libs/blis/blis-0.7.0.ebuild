# Copyright 2019-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{6,7,8} )
inherit python-any-r1

DESCRIPTION="BLAS-like Library Instantiation Software Framework"
HOMEPAGE="https://github.com/flame/blis"
SRC_URI="https://github.com/flame/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

SOV=3

LICENSE="BSD"
SLOT="0/${SOV}"
KEYWORDS="~amd64 ~ppc64 ~x86"
IUSE="blas openmp pthread serial static-libs eselect-ldso doc index-64bit"
# TODO: create a .pc for libblis.so

REQUIRED_USE="
	?? ( openmp pthread serial )
	?? ( eselect-ldso index-64bit )
	eselect-ldso? ( blas )
	"

BDEPEND="dev-util/patchelf"
RDEPEND="
	blas? ( 
		eselect-ldso? (
			!app-eselect/eselect-cblas
			>=app-eselect/eselect-blas-0.2
		)
		!eselect-ldso? (
			!app-eselect/eselect-cblas
			!app-eselect/eselect-blas

			!sci-libs/lapack[blas]
			!sci-libs/openblas
		)
	)
	"

DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	"

PATCHES=(
	"${FILESDIR}/${PN}-0.6.0-rpath.patch"
)
#"${FILESDIR}/${PN}-0.6.0-blas-provider.patch"

src_configure() {
	local BLIS_FLAGS=()
	local confname
	# determine flags
	if use openmp; then
		BLIS_FLAGS+=( -t openmp )
	elif use pthread; then
		BLIS_FLAGS+=( -t pthreads )
	else
		BLIS_FLAGS+=( -t no )
	fi
	use index-64bit && BLIS_FLAGS+=( -b 64 -i 64 )
	# determine config name
	case "${ARCH}" in
		"x86" | "amd64")
			confname=auto ;;
		"ppc64")
			confname=generic ;;
		*)
			confname=generic ;;
	esac
	# This is not an autotools configure file. We don't use econf here.
	./configure \
		--enable-verbose-make \
		--prefix="${BROOT}"/usr \
		--libdir="${BROOT}"/usr/$(get_libdir) \
		$(use_enable static-libs static) \
		$(use_enable blas) \
		$(use_enable blas cblas) \
		"${BLIS_FLAGS[@]}" \
		--enable-shared \
		$confname || die
}

#src_compile() {
	#DEB_LIBBLAS=libblas.so.${SOV} DEB_LIBCBLAS=libcblas.so.${SOV} \
	#		LDS_BLAS="${FILESDIR}"/blas.lds LDS_CBLAS="${FILESDIR}"/cblas.lds \
	#		default
#}

src_test() {
	emake check
}

src_install() {
	default
	use doc && dodoc README.md docs/*.md

	if use blas && use eselect-ldso; then
		local libdir=usr/$(get_libdir)/blas/blis
		dodir /${libdir}
		insinto /${libdir}

		local prov
		for prov in blas cblas
		do
			# Option A: patch build to create provider libraries
			#doins lib/*/lib${prov}.so lib${prov}.so.${SOV}

			# Option B: use the library as a drop-in replacement
			newlib lib/*/libblis.so lib${prov}.so.${SOV}
			patchelf --set-soname "lib${prov}.so.${SOV}" \
				${ED}/${destdir}/lib${prov}.so.${SOV}

			dosym lib${prov}.so.${SOV} ${libdir}/lib${prov}.so
		done
	elif use blas; then
		#dodir /usr/$(get_libdir)
		#insinto /usr/$(get_libdir)

		# Install as lib{,c}blas.so, let it conflict with other providers;
		# there is no way around the conflict, even if you
		# install the library under a private name and provide a pkgconfig
		# .pc that points to it, that pkgconfig file will become the
		# point of conflict -- ultimately, one provider must be chosen
		# to be installed in the system, so that dependees can find it.
		# Even if dependees are clever to look for all/any BLAS providers,
		# that doesn't help, because it creates non-determinism.
		#doins lib/*/lib{,c}blas.so.${SOV}
		#dosym libblas.so.${SOV} usr/$(get_libdir)/libblas.so
		#dosym libcblas.so.${SOV} usr/$(get_libdir)/libcblas.so

		insinto /usr/$(get_libdir)/pkgconfig
		cat <<-EOF > blas.pc
		prefix=${EPREFIX}/usr
		libdir=\${prefix}/$(get_libdir)
		Name: blas
		Description: ${DESCRIPTION}
		Version: ${PV}
		URL: ${HOMEPAGE}
		Libs: -L\${libdir} -l${PN}
		EOF
		doins blas.pc
		cat <<-EOF > cblas.pc
		prefix=${EPREFIX}/usr
		libdir=\${prefix}/$(get_libdir)
		Name: cblas
		Description: ${DESCRIPTION} (C interface)
		Version: ${PV}
		URL: ${HOMEPAGE}
		Libs: -L\${libdir} -l${PN}
		Cflags: -I\${prefix}/include/${PN}
		EOF
		doins cblas.pc
	fi
}

pkg_postinst() {
	use eselect-ldso || return

	local libdir=$(get_libdir) me="blis"

	# check blas
	eselect blas add ${libdir} "${EROOT}"/usr/${libdir}/blas/${me} ${me}
	local current_blas=$(eselect blas show ${libdir} | cut -d' ' -f2)
	if [[ ${current_blas} == "${me}" || -z ${current_blas} ]]; then
		eselect blas set ${libdir} ${me}
		elog "Current eselect: BLAS/CBLAS ($libdir) -> [${current_blas}]."
	else
		elog "Current eselect: BLAS/CBLAS ($libdir) -> [${current_blas}]."
		elog "To use blas [${me}] implementation, you have to issue (as root):"
		elog "\t eselect blas set ${libdir} ${me}"
	fi
}

pkg_postrm() {
	use eselect-ldso && eselect blas validate
}
