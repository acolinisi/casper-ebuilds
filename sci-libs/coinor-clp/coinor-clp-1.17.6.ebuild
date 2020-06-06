# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit multilib toolchain-funcs

MYPN=Clp

DESCRIPTION="COIN-OR Linear Programming solver"
HOMEPAGE="
	https://github.com/coin-or/Clp
	https://projects.coin-or.org/Clp/
"
SRC_URI="https://github.com/coin-or/${MYPN}/archive/releases/${PV}.tar.gz"

LICENSE="EPL-1.0"
SLOT="0/1"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE="doc examples glpk metis mumps sparse static-libs test"
RESTRICT="!test? ( test )"

BDEPEND="
	virtual/pkgconfig
	doc? ( app-doc/doxygen[dot] )
	test? ( sci-libs/coinor-sample )
	"
RDEPEND="
	virtual/blas
	virtual/lapack
	>=sci-libs/coinor-osi-0.108.6:=
	>=sci-libs/coinor-utils-2.11.4:=
	glpk? ( <=sci-mathematics/glpk-4.60:= sci-libs/amd )
	metis? ( || ( sci-libs/metis sci-libs/parmetis ) )
	mumps? ( sci-libs/mumps )
	sparse? ( sci-libs/cholmod )"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${MYPN}-releases-${PV}/${MYPN}"

PATCHES=(
	"${FILESDIR}"/${PN}-1.17.5-mpi_header.patch
	"${FILESDIR}"/${PN}-1.17.5-dynamic_cast.patch
)

src_prepare() {
	# needed for the --with-coin-instdir
	dodir /usr
	if has_version sci-libs/mumps[-mpi]; then
		ln -s "${EPREFIX}"/usr/include/mpiseq/mpi.h src/mpi.h
	elif has_version sci-libs/mumps[mpi]; then
		export CXX=mpicxx
	fi
	sed -i \
		-e "s:lib/pkgconfig:$(get_libdir)/pkgconfig:g" \
		configure || die
	default
}

src_configure() {
	# WSMP library from IBM requires a paid license, so disable
	local myeconfargs=(
		--enable-aboca
		--enable-dependency-linking
		--without-wsmp
		--with-coin-instdir="${ED}"/usr
		--with-blas
		--with-blas-lib="$($(tc-getPKG_CONFIG) --libs blas)" \
		--with-lapack
		--with-lapack-lib="$($(tc-getPKG_CONFIG) --libs lapack)" \
		$(use_with doc dot)
	)
	if use glpk; then
		myeconfargs+=(
			--with-amd-incdir="${EPREFIX}"/usr/include
			--with-amd-lib=-lamd
			--with-glpk-incdir="${EPREFIX}"/usr/include
			--with-glpk-lib=-lglpk )
	else
		myeconfargs+=( --without-glpk )
	fi
	if use sparse; then
		myeconfargs+=(
			--with-amd-incdir="${EPREFIX}"/usr/include
			--with-amd-lib=-lamd
			--with-cholmod-incdir="${EPREFIX}"/usr/include
			--with-cholmod-lib=-lcholmod )
	else
		myeconfargs+=( --without-amd --without-cholmod )
	fi
	if use metis; then
		myeconfargs+=(
			--with-metis-incdir="$($(tc-getPKG_CONFIG) --cflags metis | sed 's/-I//g')"
			--with-metis-lib="$($(tc-getPKG_CONFIG) --libs metis)" )
	else
		myeconfargs+=( --without-metis )
	fi
	if use mumps; then
		myeconfargs+=(
			--with-mumps-lib="$($(tc-getPKG_CONFIG) --cflags mumps | sed 's/-I//g')"
			--with-mumps-lib="$($(tc-getPKG_CONFIG) --libs mumps)"
			)
	else
		myeconfargs+=( --without-mumps )
	fi
	# Note: append-*flags and setting {C,CXX}FLAGS does not have effect
	local DEFS=()
	DEFS+=("-DABC_INHERIT") # doesn't compile without this
	DEFS+=("-DTHREADS_IN_ANALYZE") # not use flag b/c doesn't compile without

	CDEFS="${DEFS[@]}" CXXDEFS="${DEFS[@]}" econf "${myeconfargs[@]}"
}

src_compile() {
	emake all $(usex doc doxydoc "")
}

src_test() {
	emake test
}

src_install() {
	use doc && HTML_DOC=("${BUILD_DIR}/doxydocs/html/")
	default
	# already installed
	rm "${ED}"/usr/share/coin/doc/${MYPN}/{README,AUTHORS,LICENSE} || die
	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}
