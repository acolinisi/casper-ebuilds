# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 firedrake

MY_PN=PyOP2
MY_FV=$(ver_cut 1)

DESCRIPTION="Framework for performance-portable parallel computations on unstructured meshes"
HOMEPAGE="https://github.com/OP2/PyOP2 http://op2.github.com/PyOP2"
SRC_URI="https://github.com/OP2/${MY_PN}/archive/Firedrake_${PV}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}/${MY_PN}-Firedrake_${PV}"

LICENSE="BSD"

# Even if this package itself is not forked, as long as as it depends on an
# 'fd' slot (i.e. Firedrake's fork) of a dependency, this package is also
# quarantined into 'fd' slot as well. If/when Firedrake merges the fork into
# upstream, we can change to SLOT=0 here.
SLOT="fd"

KEYWORDS="amd64 ~amd64-linux"
IUSE="complex-scalars index-64bit"

BDEPEND="
 	$(python_gen_cond_dep \
	'
	>=dev-python/pytest-2.3[${PYTHON_MULTI_USEDEP}]
	>=dev-python/flake8-2.1.0[${PYTHON_MULTI_USEDEP}]
	')
	"
DEPEND="
	sci-mathematics/petsc[complex-scalars=,index-64bit=]
 	$(python_gen_cond_dep \
		'>=dev-python/cython-0.22[${PYTHON_MULTI_USEDEP}]')
	"
# TODO: mpi use flag?
RDEPEND="${DEPEND}
	=dev-python/coffee-${MY_FV}*[${PYTHON_SINGLE_USEDEP}]
	=dev-python/loopy-${MY_FV}*:fd[${PYTHON_SINGLE_USEDEP}]
 	$(python_gen_cond_dep \
	'
	dev-python/decorator[${PYTHON_MULTI_USEDEP}]
	>=dev-python/mpi4py-1.3.1[${PYTHON_MULTI_USEDEP}]
	>=dev-python/numpy-1.9.1[${PYTHON_MULTI_USEDEP}]
	dev-python/petsc4py[${PYTHON_MULTI_USEDEP}]
	>=dev-python/pycparser-2.10[${PYTHON_MULTI_USEDEP}]
	dev-python/pymbolic[${PYTHON_MULTI_USEDEP}]
	dev-python/pytools[${PYTHON_MULTI_USEDEP}]
	')
	"

python_test()
{
	pushd test/unit
	pytest || die
	popd
}

python_install_all()
{
	distutils-r1_python_install_all
	firedrake_install
}
