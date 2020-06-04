# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )

inherit distutils-r1

DESCRIPTION="Python bindings for PETSc"
HOMEPAGE="https://bitbucket.org/petsc4py/ https://pypi.org/project/petsc4py/"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 ~amd64-linux"
IUSE="complex-scalars index-64bit doc examples mpi test"

# With MPI, tests fail with segfault in PETSc
RESTRICT="mpi? ( test )"

BDEPEND="
	dev-python/cython[${PYTHON_USEDEP}]
	"
RDEPEND="
	sci-mathematics/petsc:=[complex-scalars=,index-64bit=]
	dev-python/numpy[${PYTHON_USEDEP}]
	mpi? ( dev-python/mpi4py[${PYTHON_USEDEP}] )
	"
DEPEND="${RDEPEND}"

DISTUTILS_IN_SOURCE_BUILD=1

python_prepare_all() {
	# not needed on install
	rm -vr docs/source || die
	distutils-r1_python_prepare_all
}

python_test() {
	echo "Beginning test phase"
	pushd "${BUILD_DIR}"/../ &> /dev/null || die
	if use mpi; then
		mpiexec -n 2 "${PYTHON}" ./test/runtests.py -v
	else
		"${PYTHON}" ./test/runtests.py -v
	fi || die "Testsuite failed under ${EPYTHON}"
	popd &> /dev/null || die
}

python_install_all() {
	use doc && local HTML_DOCS=( docs/. )
	use examples && local DOCS=( demo )
	distutils-r1_python_install_all
}
