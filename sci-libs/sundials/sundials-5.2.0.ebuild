# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CMAKE_MAKEFILE_GENERATOR="emake"
FORTRAN_NEEDED=fortran
FORTRAN_STANDARD="77 90"
# if FFLAGS and FCFLAGS are set then should be equal

inherit cmake fortran-2 toolchain-funcs

DESCRIPTION="Suite of nonlinear solvers"
HOMEPAGE="https://computing.llnl.gov/projects/sundials"
SRC_URI="https://computing.llnl.gov/projects/sundials/download/${P}.tar.gz"

LICENSE="BSD"
SLOT="0/$(ver_cut 1)"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
# TODO: cuda
IUSE="doc examples fortran hypre index-64bit lapack mpi openmp sparse static-libs superlu_mt superlu_dist threads"
REQUIRED_USE="
	hypre? ( mpi )
	superlu_mt? ( ?? ( openmp threads ) )
	"

BDEPEND="virtual/pkgconfig"
RDEPEND="
	lapack? ( virtual/lapack virtual/blas )
	mpi? ( virtual/mpi sci-libs/hypre:= )
	sparse? ( sci-libs/klu )
	superlu_mt? ( sci-libs/superlu_mt:=[openmp?,index-64bit?] )
	superlu_dist? ( >=sci-libs/superlu_dist-6.3.0:=[openmp?,index-64bit?] )
"
DEPEND="${RDEPEND}"

# NOTE: there's also a sed command patch in src_prepare
PATCHES=(
	"${FILESDIR}"/${P}-fix-license-install-path.patch
	"${FILESDIR}"/${P}-blas.patch
	"${FILESDIR}"/${P}-superlu_mt.patch
	)
# Breaks linking
#"${FILESDIR}"/${P}-blas.patch
#"${FILESDIR}"/${P}-lapack-libs.path
# TODO: fix examples (rules borken when with LAPACK_LIBRARIES, but linking
# broken when without... possibly because of the above lapack-libs.patch )
#"${FILESDIR}"/${P}-examples-lapack-libs.path

pkg_setup() {
	if [[ ${MERGE_TYPE} != binary ]] && use openmp && [[ $(tc-getCC) == *gcc ]] && ! tc-has-openmp; then
		ewarn "OpenMP is not available in your current selected gcc"
		die "need openmp capable gcc"
	fi
}

src_prepare() {
	# Interface changed in superlu_dist >=6.3.0;
	# note: sci-libs/superlu_dist builds double precision unconditionally
	# TODO: might add a double-precision flag
	if use superlu_dist; then
		find \
			include/sunlinsol/sunlinsol_superludist.h \
			src/sunlinsol/superludist/ \
			examples/sunlinsol/superludist/ \
			examples/arkode/CXX_superludist/ \
			examples/cvode/superludist/ \
			-type f -execdir \
			sed -i 's/\(LU\|ScalePerm\|SOLVE\)struct_t/d\1struct_t/g' {} \;
	fi
	cmake_src_prepare
}

# TODO: QA warning about RPATH in fnvecparallel library
# TODO: upstream ignores PTHREAD_ENABLE=no
# TODO: LAPACK_LIBRARIES="-llapack -lblas|-lopenblas" is not good,
# need automatic detection because we don't know which provider is installed
# -DLAPACK_LIBRARIES="-llapack -lblas"
		#-DSUPERLUMT_LIBRARIES="-lsuperlu_mt"
		#-DSUPERLUDIST_LIBRARIES="-lsuperlu_dist"

		#-DCXX_ENABLE="$(usex cxx)"
		#-DF90_ENABLE="$(usex fortran)"
		#-DLAPACK_LIBRARY_DIR="${EPREFIX}/usr/$(get_libdir)"
src_configure() {
	local mycmakeargs+=(
		-DBUILD_SHARED_LIBS=ON
		-DBUILD_STATIC_LIBS="$(usex static-libs)"
		-DCMAKE_SKIP_BUILD_RPATH=ON
		-DCMAKE_BUILD_WITH_INSTALL_RPATH=OFF
		-DCMAKE_INSTALL_RPATH_USE_LINK_PATH=OFF
		-DSUNDIALS_PRECISION=double
		-DSUNDIALS_INDEX_SIZE=$(usex index-64bit 64 32)
		-DCUDA_ENABLE=OFF
		-DF77_INTERFACE_ENABLE="$(usex fortran)"
		-DHYPRE_ENABLE="$(usex hypre)"
		-DKLU_ENABLE="$(usex sparse)"
		-DLAPACK_ENABLE="$(usex lapack)"
		-DMPI_ENABLE="$(usex mpi)"
		-DOPENMP_ENABLE="$(usex openmp)"
		-DPTHREAD_ENABLE="$(usex threads)"
		-DPETSC_ENABLE=OFF
		-DRAJA_ENABLE=OFF
		-DTrilinos_ENABLE=OFF
		-DSUPERLUMT_ENABLE="$(usex superlu_mt)"
		-DSUPERLUDIST_ENABLE="$(usex superlu_dist)"
		-DEXAMPLES_ENABLED="$(usex examples)"
		-DEXAMPLES_ENABLE_C="$(usex examples)"
		-DEXAMPLES_ENABLE_CXX="$(usex examples)"
		-DEXAMPLES_ENABLE_F77="$(usex examples)"
		-DEXAMPLES_ENABLE_F90="$(usex examples)"
		-DEXAMPLES_INSTALL="$(usex examples)"
		-DEXAMPLES_INSTALL_PATH="${EPREFIX}/usr/share/doc/${PF}/examples"
		-DUSE_GENERIC_MATH=ON
	)

	# Set these conditionally, to reduce noise and warnings about unused vars

	if use hypre; then
		mycmakeargs+=(
				-DHYPRE_INCLUDE_DIR="${EPREFIX}/usr/include/hypre"
				-DHYPRE_LIBRARY_DIR="${EPREFIX}/usr/$(get_libdir)"
		)
	fi
	if use sparse; then
		mycmakeargs+=(
				-DKLU_LIBRARY_DIR="${EPREFIX}/usr/$(get_libdir)"
		)
	fi
	if use superlu_mt; then
		mycmakeargs+=(
			-DSUPERLUMT_THREAD_TYPE="$(usex openmp OPENMP PTHREAD)"
			-DSUPERLUMT_INCLUDE_DIR="${EPREFIX}/usr/include/superlu_mt"
			-DSUPERLUMT_LIBRARY_DIR="${EPREFIX}/usr/$(get_libdir)"
			-DSUPERLUMT_LIBRARY_NAME="superlu_mt"
		)
	fi
	if use superlu_dist; then
		mycmakeargs+=(
			-DSUPERLUDIST_OpenMP="$(usex openmp)"
			-DSUPERLUDIST_INCLUDE_DIR="${EPREFIX}/usr/include/superlu_dist"
			-DSUPERLUDIST_LIBRARY_DIR="${EPREFIX}/usr/$(get_libdir)"
		)
	fi
	cmake_src_configure
}

src_install() {
	cmake_src_install

	# dolfin needs it...
	insinto /usr/include/cvode/
	doins src/cvode/cvode_impl.h

	use doc && dodoc doc/*/*.pdf
}
