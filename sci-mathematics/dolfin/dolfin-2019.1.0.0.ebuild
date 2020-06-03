# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_8 )

# We only need Python to build, but we need the particular one where
# dev-python/fcc was (and dev-python/dolfin will be) installed into,
# so we can't use python-any-r1.
inherit cmake python-single-r1

DESCRIPTION="C++/Python interface of FEniCS"
HOMEPAGE="https://bitbucket.org/fenics-project/dolfin"
MAIN_PV=$(ver_cut 1-3)
MYP=${PN}-${MAIN_PV}.post$(ver_cut 4)
SRC_URI="https://bitbucket.org/fenics-project/${PN}/downloads/${MYP}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~amd64-linux"
IUSE="hdf5 mpi parmetis petsc python scotch slepc sundials test trilinos umfpack zlib vtk"

REQUIRED_USE="${PYTHON_REQUIRED_USE}
	trilinos? ( mpi )"

# CMake build system invokes python and imports ffc, numpy,
# so add to BDEPEND besides adding to RDEPEND
MY_PY_BUILD_DEPEND="
	=dev-python/ffc-${MAIN_PV}*:0[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep \
		'dev-python/numpy[${PYTHON_MULTI_USEDEP}]')
	"

# Native piece seems to use pytest for testing (TODO: double-check)
BDEPEND="${PYTHON_DEPS} ${MY_PY_BUILD_DEPEND}
	$(python_gen_cond_dep \
		'test?  ( dev-python/pytest[${PYTHON_MULTI_USEDEP}] )' \
	)
"
# TODO: these are known upper bounds, but what is the tightest upper bound?
# 	sundials 5.2.0 imcompatible
# 	hdf5 1.12.0 imcompatible
# 	trilinos 12.18 imcompatible
# TODO: why bzip2 disable for scotch?
# Depend on slot 0 ("mainline"), to forbid slot 'fd' (Firedrake fork)
DEPEND="
	>=dev-cpp/eigen-3.2.90:3
	dev-libs/boost:=
	dev-libs/libxml2:2
	virtual/blas
	virtual/lapack
	hdf5? ( <sci-libs/hdf5-1.12[mpi=] )
	mpi? ( virtual/mpi )
	parmetis? ( >=sci-libs/parmetis-4.0.2[mpi(+)] )
	petsc? ( >=sci-mathematics/petsc-3.7[mpi=] )
	slepc? ( >=sci-mathematics/slepc-3.7[mpi=] )
	sci-libs/armadillo
	scotch? ( sci-libs/scotch[-bzip2] )
	sundials? ( >=sci-libs/sundials-3 )
	trilinos? ( <sci-libs/trilinos-12.18 )
	umfpack? (
		sci-libs/amd
		sci-libs/cholmod
		sci-libs/umfpack
	)
	vtk? ( sci-libs/vtk )
	zlib? ( sys-libs/zlib )
	"
RDEPEND="${DEPEND} ${MY_PY_BUILD_DEPEND}"

S="${WORKDIR}/${MYP}"

#"${FILESDIR}"/${P}-cholmod-pthread.patch
PATCHES=(
	"${FILESDIR}"/${PN}-2016.2.0-trilinos-superlu.patch
	"${FILESDIR}"/${P}-try-run-rpath.patch
)

#pkg_setup() {
#	python-single-r1_pkg_setup
#}

#src_prepare() {
#	default
#}

src_configure() {
	# *sigh*
	addpredict /proc/mtrr
	addpredict /sys/devices/system/cpu/

	# TODO: reported as unused
	#-DDOLFIN_ENABLE_VTK="$(usex vtk)"
	mycmakeargs=(
		-DCMAKE_INSTALL_RPATH_USE_LINK_PATH=OFF
		-DCMAKE_SKIP_RPATH=ON
		-DDOLFIN_TRY_RUN_CMAKE_FLAGS="-DCMAKE_SKIP_RPATH:BOOL=ON"
		-DDOLFIN_ENABLE_CHOLMOD="$(usex umfpack)"
		-DDOLFIN_ENABLE_HDF5="$(usex hdf5)"
		-DDOLFIN_ENABLE_MPI="$(usex mpi)"
		-DDOLFIN_ENABLE_PARMETIS="$(usex parmetis)"
		-DDOLFIN_ENABLE_PETSC="$(usex petsc)"
		-DDOLFIN_ENABLE_SCOTCH="$(usex scotch)"
		-DDOLFIN_ENABLE_SLEPC="$(usex slepc)"
		-DDOLFIN_ENABLE_SUNDIALS="$(usex sundials)"
		$(usex sundials -DSUNDIALS_DIR="${EPREFIX}/usr" "")
		-DDOLFIN_ENABLE_TRILINOS="$(usex trilinos)"
		-DDOLFIN_ENABLE_UMFPACK="$(usex umfpack)"
		-DDOLFIN_ENABLE_ZLIB="$(usex zlib)"
	)
	cmake_src_configure
}

src_compile() {
	cmake_src_compile
	#if use python; then
	#	cd python
	#	python setup.py build
	#fi

}

src_install() {
	cmake_src_install
	#default
	#if use python; then
	#	cd python
	#	# TODO: --optimize does not work?
	#	export CMAKE_MODULE_PATH=/staging/jnw2/acolin/casper/glprefix/var/tmp/portage/sci-mathematics/dolfin-2019.1.0.0/work/dolfin-2019.1.0.post0/cmake/modules
	#	DOLFIN_DIR="${WORKDIR}/${P}_build/dolfin" \
	#		python setup.py install --prefix="${EPREFIX}/usr" --root="${D}" \
	#		--optimize=1
	#	python_optimize
	#fi
}
