# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs flag-o-matic

#SOVER=$(get_major_version)

DESCRIPTION="Software for graph, mesh and hypergraph partitioning"
HOMEPAGE="http://www.labri.u-bordeaux.fr/perso/pelegrin/scotch/"

SRC_URI="https://gitlab.inria.fr/scotch/scotch/-/archive/v${PV}/${PN}-v${PV}.tar.gz"
S=${WORKDIR}/${PN}-v${PV}

# Alternative source:
# use esmumps version to allow linking with mumps
#MYP="${PN}_${PV}_esmumps"
# download id on gforge changes every goddamn release
#DID=38187
#SRC_URI="http://gforge.inria.fr/frs/download.php/${DID}/${MYP}.tar.gz"
#S=${WORKDIR}/${P/-/_}

LICENSE="CeCILL-2"
SLOT="0/$(ver_cut 1)"
KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc x86 ~amd64-linux ~x86-linux"
IUSE="bzip2 doc index-64bit mpi static-libs tools threads +zlib"

DEPEND="
	zlib? ( sys-libs/zlib )
	bzip2? ( app-arch/bzip2 )
	mpi? ( virtual/mpi )"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}"/${P}-flex-2.6.3-fix.patch
)

src_unpack() {
	default
	if use static-libs; then
		cp -a "${S}"/src{,-static}
	fi
}

src_prepare() {
	default

	# The diff beween i686 and x86-64 is -DIDXSIZE64; we append it manually
	local make_inc=src/Make.inc/Makefile.inc.i686_pc_linux2

	cp "${make_inc}.shlib" src/Makefile.inc || die

	if use static-libs; then
		cp "${make_inc}" src-static/Makefile.inc || die
	fi

	use index-64bit && append-cflags "-DIDXSIZE64 -DINTSIZE64"
	if use threads; then
		append-cflags "-DSCOTCH_PTHREAD -DSCOTCH_PTHREAD_NUMBER=$(nproc)"
		append-cflags "-pthread"
	else
		# TODO: is this necessary?
		append-cflags "-DSCOTCH_PTHREAD_NUMBER=1"
	fi
	if use zlib; then
		append-cflags "-DCOMMON_FILE_COMPRESS_GZ"
		append-libs "-lz"
	fi
	if use bzip2; then
		append-cflags "-DCOMMON_FILE_COMPRESS_BZ2"
		append-libs "-lbz2"
	fi

	# full paths, clear settings that we set based on use, and apply flags
	sed -i -e "s/gcc/$(tc-getCC)/g" \
		-e "s/ ar/ $(tc-getAR)/g" \
		-e "s/ranlib/$(tc-getRANLIB)/g" \
		-e "s/-O3//g" \
		-e "s/ -pthread//g" \
		-e "s/ -DCOMMON_FILE_COMPRESS_\(GZ\|BZ2\|LZMA\)//g" \
		-e "s/ -l\(z\|bz2\)//g" \
		-e "s/ -D\(SCOTCH_PTHREAD\|SCOTCH_PTHREAD_NUMBER=\d*\)//g" \
		-e "s/ -D\(IDX\|INT\)SIZE64//g" \
		-e "s/^\(CFLAGS\s*=\s*\)/\1${CFLAGS} /" \
		-e "s/^\(LDFLAGS\s*=\s*\)/\1${LDFLAGS} ${LIBS} /" \
		-e "$ a SONAME_VER = $(ver_cut 1)" \
		src/Makefile.inc \
		$(usex static-libs src-static/Makefile.inc "") || die

	# Add SONAMEs to shared libraries (note: upstream uses same targets
	# as for static and hackishly overrides $AR $ARFLAGS to gcc -shared -o).
	# Assuming that upstream respects semantic version number...
	find src -name Makefile -execdir sed -i \
		"s/\(\$(AR)\s*\$(ARFLAGS) \$(@)\)/\1 -Wl,-soname=\$(@).\$(SONAME_VER)/" \
		{} \;
}

src_compile() {
	# Parallel build is borken, somewhere near libesmumps.so
	export MAKEOPTS=-j1

	local TARGETS=(scotch esmumps)
	if use mpi; then
		TARGETS+=(ptscotch ptesmumps)
	fi

	emake -C src ${TARGETS[@]}
	if use static-libs; then
		emake -C src-static ${TARGETS[@]}
	fi
}

src_test() {
	LD_LIBRARY_PATH="${S}/lib" emake -C src check $(usex mpi ptscheck "")
}

src_install() {
	local MAKE_VARS=(
		prefix="${ED}/usr"
		bindir="${ED}/usr/bin"
		libdir="${ED}/usr/$(get_libdir)"
		includedir="${ED}/usr/include/${PN}"
		includestubdir="${ED}/usr/include/${PN}/metis"
		mandir="${ED}/usr/share/man"
	)
	emake -C src ${MAKE_VARS[@]} install installstub

	# Upstream doesn't create symbolic links (consumers need them)
	LIBS=(
		libscotch.so
		libscotcherr.so
		libscotcherrexit.so
		libscotchmetis.so
		libesmumps.so
	)
	if use mpi; then
		LIBS+=(
			libptscotch.so
			libptscotcherr.so
			libptscotcherrexit.so
			libptscotchparmetis.so
			libptesmumps.so
		)
	fi

	local SOV=$(ver_cut 1)
	pushd ${ED}/usr/$(get_libdir)/
	for lib in ${LIBS[@]}; do
		mv ${lib}{,.${PV}}
		ln -sf ${lib}{.${PV},.${SOV}}
		ln -sf ${lib}{.${SOV},}
	done || die
	popd

	if use static-libs; then
		emake -C src-static ${MAKE_VARS[@]} install
	fi

	insinto /usr/$(get_libdir)/pkgconfig

	local DEP_LIBS=(-lm -lrt
		$(usex zlib "-lz" "")
		$(usex bzip2 "-lbz2" ""))
	local SEQ_LIBS=(-lscotch -lscotcherr)
	local PAR_LIBS=(-lptscotch -lptscotcherr)

	cat <<-EOF > scotch.pc
	prefix=${EPREFIX}/usr
	libdir=\${prefix}/$(get_libdir)
	Name: scotch
	Description: ${DESCRIPTION}
	Version: ${PV}
	URL: ${HOMEPAGE}
	Libs: -L\${libdir} -lesmumps ${SEQ_LIBS[@]} ${DEP_LIBS[@]}
	Cflags: -I\${prefix}/include/${PN}
	EOF
	doins scotch.pc

	if use mpi; then
		# At least in case of PETSc, sequential libraries are
		# also required when using parallel libraries.
		cat <<-EOF > ptscotch.pc
		prefix=${EPREFIX}/usr
		libdir=\${prefix}/$(get_libdir)
		Name: scotchmetis
		Description: ${DESCRIPTION}
		Version: ${PV}
		URL: ${HOMEPAGE}
		Libs: -L\${libdir} -lptesmumps ${PAR_LIBS[@]}
		Requires: scotch
		Cflags: -I\${prefix}/include/${PN}
		EOF
		doins ptscotch.pc
	fi

	cat <<-EOF > scotchmetis.pc
	prefix=${EPREFIX}/usr
	libdir=\${prefix}/$(get_libdir)
	Name: scotchmetis
	Description: ${DESCRIPTION}
	Version: ${PV}
	URL: ${HOMEPAGE}
	Libs: -L\${libdir} -lscotchmetis ${SEQ_LIBS[@]} ${DEP_LIBS[@]}
	Cflags: -I\${prefix}/include/${PN}/metis
	EOF
	doins scotchmetis.pc

	if use mpi; then
		cat <<-EOF > ptscotchparmetis.pc
		prefix=${EPREFIX}/usr
		libdir=\${prefix}/$(get_libdir)
		Name: ptscotchparmetis
		Description: ${DESCRIPTION}
		Version: ${PV}
		URL: ${HOMEPAGE}
		Libs: -L\${libdir} -lptscotchparmetis ${PAR_LIBS[@]} ${DEP_LIBS[@]}
		Cflags: -I\${prefix}/include/${PN}/metis
		Requires: scotchmetis
		EOF
		doins ptscotchparmetis.pc
	fi

	# rename binaries to prefix with scotch_
	if use tools; then
		local b m
		pushd ${ED}/usr/bin > /dev/null
		for b in *; do
			newbin ${b} scotch_${b}
			rm "${b}"
		done
		popd > /dev/null

		pushd ${ED}/usr/share/man/man1 > /dev/null
		for m in *; do
			newman ${m} scotch_${m}
			rm "${m}"
		done
		popd > /dev/null
	else
		find ${ED}/usr/bin ${ED}/usr/share/man -delete
	fi

	dodoc README.txt
	use doc && dodoc doc/*.pdf
}
