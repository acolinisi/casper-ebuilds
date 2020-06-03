# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Note: in python3.6 this script
# 	cmake_modules/morse_cmake/modules/precision_generator/codegen.py 
# fails to read files ('r' mode) with unicode: breaks bcsc_znorm.c
PYTHON_COMPAT=( python3_8 )

inherit cmake cuda fortran-2 toolchain-funcs python-single-r1

# TODO:
# testing: emake examples?
# better doc instalation and building
# pypastix (separate package?)
# multilib with eselect?
# static libs building without pic
# metis?

# release asset contains submodules whichfrom source code asset does not
REL_HASH=98ce9b47514d0ee2b73089fe7bcb3391
DESCRIPTION="Parallel solver for very large sparse linear systems"
HOMEPAGE="http://pastix.gforge.inria.fr"
SRC_URI="https://gitlab.inria.fr/solverstack/pastix//uploads/${REL_HASH}/${P}.tar.gz"

LICENSE="CeCILL-C"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~amd64-linux ~x86-linux"
#TODO: parsec
#PASTIX_WITH_PARSEC[=OFF]: Enable/disable the PaRSEC runtime support.
#Require to install PaRSEC tag pastix-releasenumber (mymaster for master
#branch) from the repository https://bitbucket.org/mfaverge/parsec that
#includes a few patches on top of the original PaRSEC runtime system.
#PaRSEC needs to be compiled with option -DPARSEC_WITH_DEVEL_HEADERS=ON.
# TODO: eztrace
IUSE="cuda doc examples fortran index-64bit metis mpi python scotch starpu static-libs test debug"

#RDEPEND="
#	sci-libs/scotch:0=[int64?,mpi?]
#	sys-apps/hwloc:0=
#	virtual/blas
#	mpi? ( virtual/mpi )
#	starpu? ( dev-libs/starpu:0= )"
#DEPEND="${RDEPEND}
#	virtual/pkgconfig"


# TODO: does metis also have int64 option? (pastix instructions
# seem to imply it does)
# TODO: when upstream releases SpM library, package it and switch to
# external
# TODO: should blas be index-64bit?
# TODO: very strange: for metis, idx_t=IDXTYPEWIDTH (not REALTYPEWIDTH)
# is checked, but for scotch INTSIZE64 (not IDXSIZE64) is checked...
# TODO: scotch: mpi? or mpi= : seems to work (up until solver) with scotch[mpi] while we are -mpi -- double-check
BDEPEND="
	virtual/pkgconfig
	test? ( sci-libs/tmglib )
	"
RDEPEND="
	sys-apps/hwloc:0=
	virtual/blas
	virtual/cblas
	virtual/lapack
	virtual/lapacke
	cuda? ( dev-util/nvidia-cuda-toolkit )
	metis? ( sci-libs/parmetis[index-64bit=] )
	mpi? ( virtual/mpi )
	scotch? ( sci-libs/scotch:0=[index-64bit=,mpi?] )
	starpu? ( >=dev-libs/starpu-1.3:0= )
	python? ( $(python_gen_cond_dep \
			'dev-python/numpy[${PYTHON_MULTI_USEDEP}]') )
	"
DEPEND="${RDEPEND}"

#S="${WORKDIR}/${PN}_${PV}/src"

PATCHES=(
	"${FILESDIR}"/${P}-optional-python-wrapper.patch
	"${FILESDIR}"/${P}-optional-tests-and-examples.patch
	"${FILESDIR}"/${P}-spm-subproject.patch
	"${FILESDIR}"/${P}-lib-dir.patch
	"${FILESDIR}"/${P}-cmake-spm-option.patch
	"${FILESDIR}"/${P}-cmake-starpu-libs.patch
	)

src_prepare() {
	cmake_src_prepare
	use cuda && cuda_src_prepare
}

my_src_configure() {
	# TODO: ptscotch is broken upstream (typos, TODOs, etc), see
	# ptscotch.patch for part of fixes,  once fixed: change to
	#   -DPASTIX_ORDERING_PTSCOTCH=$(usex scotch)
	#	-DPASTIX_DISTRIBUTED=$(usex mpi)
	# SPM library is not released, so build the bundled sources
	local mycmakeargs+=(
		-DBUILD_SHARED_LIBS=ON
		-DINSTALL_LIBDIR="$(get_libdir)"
		-DBUILD_DOCUMENTATION=$(usex doc)
		-DBUILD_EXAMPLES=$(usex examples)
		-DBUILD_TESTING=$(usex test)
		-DBUILD_SPM=ON
		-DPASTIX_DISTRIBUTED=OFF
		-DPASTIX_INT64=$(usex index-64bit)
		-DPASTIX_ORDERING_SCOTCH=$(usex scotch)
		-DPASTIX_ORDERING_PTSCOTCH=OFF
		-DPASTIX_ORDERING_METIS=$(usex metis)
		-DPASTIX_WITH_FORTRAN=$(usex fortran)
		-DPASTIX_WITH_PYTHON=$(usex python)
		-DPASTIX_WITH_PARSEC=OFF
		-DPASTIX_WITH_STARPU=$(usex starpu)
		-DPASTIX_WITH_MPI=$(usex mpi)
		-DPASTIX_WITH_CUDA=$(usex cuda)
		-DPASTIX_WITH_EZTRACE=OFF

	)
	local debug_flags=(
		PASTIX_DEBUG_GRAPH
		PASTIX_DEBUG_ORDERING
		PASTIX_DEBUG_SYMBOL
		PASTIX_DEBUG_BLEND
		PASTIX_DEBUG_DUMP_COEFTAB
		PASTIX_DEBUG_FACTO
		PASTIX_DEBUG_SOLVE
		PASTIX_DEBUG_PARSEC
		PASTIX_DEBUG_LR
		PASTIX_DEBUG_LR_NANCHECK
		PASTIX_DEBUG_GMRES
		PASTIX_DEBUG_EXIT_ON_SIGSEGV
		PASTIX_DEBUG_MPI
	)
	#if use debug; then
		#for flag in "${debug_flags[@]}"; do
		#	mycmakeargs+=(-D${flag}=ON)
		#done
	#fi
	if use python; then
		local pyver=$(ver_cut 1-2 $(python --version | sed 's/Python\s*//'))
		local mycmakeargs+=(
			-DPYTHON_SITE_PACKAGES_DIR=lib/python${pyver}/site-packages
		)
	fi
	cmake_src_configure
}

src_configure()
{
	if use cuda; then
		cuda_with_gcc my_src_configure
	else
		my_src_configure
	fi
}

src_compile()
{
	if use cuda; then
		cuda_with_gcc cmake_src_compile
	else
		cmake_src_compile
	fi
}


#src_prepare() {
#	default
#	sed -e 's/^\(HOSTARCH\s*=\).*/\1 ${HOST}/' \
#		-e "s:^\(CCPROG\s*=\).*:\1 $(tc-getCC):" \
#		-e "s:^\(CFPROG\s*=\).*:\1 $(tc-getFC):" \
#		-e "s:^\(CF90PROG\s*=\).*:\1 $(tc-getFC):" \
#		-e "s:^\(ARPROG\s*=\).*:\1 $(tc-getAR):" \
#		-e "s:^\(CCFOPT\s*=\).*:\1 ${FFLAGS}:" \
#		-e "s:^\(CCFDEB\s*=\).*:\1 ${FFLAGS}:" \
#		-e 's:^\(EXTRALIB\s*=\).*:\1 -lm -lrt:' \
#		-e "s:^#\s*\(ROOT\s*=\).*:\1 \$(DESTDIR)${EPREFIX}/usr:" \
#		-e 's:^#\s*\(INCLUDEDIR\s*=\).*:\1 $(ROOT)/include:' \
#		-e 's:^#\s*\(BINDIR\s*=\).*:\1 $(ROOT)/bin:' \
#		-e "s:^#\s*\(LIBDIR\s*=\).*:\1 \$(ROOT)/$(get_libdir):" \
#		-e 's:^#\s*\(SHARED\s*=\).*:\1 1:' \
#		-e 's:^#\s*\(SOEXT\s*=\).*:\1 .so:' \
#		-e '/fPIC/s/^#//g' \
#		-e "s:^#\s*\(SHARED_FLAGS\s*=.*\):\1 ${LDFLAGS}:" \
#		-e "s:pkg-config:$(tc-getPKG_CONFIG):g" \
#		-e "s:^\(BLASLIB\s*=\).*:\1 $($(tc-getPKG_CONFIG) --libs blas):" \
#		-e "s:^\s*\(HWLOC_HOME\s*?=\).*:\1 ${EPREFIX}/usr:" \
#		-e "s:-I\$(HWLOC_INC):$($(tc-getPKG_CONFIG) --cflags hwloc):" \
#		-e "s:-L\$(HWLOC_LIB) -lhwloc:$($(tc-getPKG_CONFIG) --libs hwloc):" \
#		-e "s:^\s*\(SCOTCH_HOME\s*?=\).*:\1 ${EPREFIX}/usr:" \
#		-e "s:^\s*\(SCOTCH_INC\s*?=.*\):\1/scotch:" \
#		-e "s:^\s*\(SCOTCH_LIB\s*?=.*\)lib:\1$(get_libdir):" \
#		config/LINUX-GNU.in > config.in || die
#	sed -e 's/__SO_NAME__,$@/__SO_NAME__,$(notdir $@)/g' -i Makefile || die
#}
#
#src_configure() {
#	if use amd64; then
#		sed -e 's/^\(VERSIONBIT\s*=\).*/\1 _64bit/' \
#			-i config.in || die
#	fi
#
#	if use int64; then
#		sed -e '/VERSIONINT.*_int64/s/#//' \
#			-e '/CCTYPES.*INTSSIZE64/s/#//' \
#			-i config.in || die
#	fi
#
#	if ! use mpi; then
#		sed -e '/VERSIONMPI.*_nompi/s/#//' \
#			-e '/CCTYPES.*NOMPI/s/#//' \
#			-e '/MPCCPROG\s*= $(CCPROG)/s/#//' \
#			-e '/MCFPROG\s*= $(CFPROG)/s/#//' \
#			-e 's/-DDISTRIBUTED//' \
#			-e 's/-lptscotch/-lscotch/g' \
#			-i config.in || die
#	fi
#
#	if ! use smp; then
#		sed -e '/VERSIONSMP.*_nosmp/s/#//' \
#			-e '/CCTYPES.*NOSMP/s/#//' \
#			-i config.in || die
#	fi
#
#	if use starpu; then
#		sed -e '/libstarpu/s/#//g' -i config.in || die
#	fi
#}
#
#src_compile() {
#	emake all drivers
#}
#
#src_test() {
#	# both test and tests targets are defined and do not work
#	emake examples
#	echo
#}
#
#src_install() {
#	default
#	sed -e "s:${D}::g" -i "${ED}"/usr/bin/pastix-conf || die
#	# quick and dirty (static libs should really be built without pic)
#	cd .. || die
#	dodoc README.txt doc/refcard/refcard.pdf
#}
