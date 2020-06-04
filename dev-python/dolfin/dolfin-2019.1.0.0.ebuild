# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_8 )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1

DESCRIPTION="Python interface of FEniCS"
HOMEPAGE="https://bitbucket.org/fenics-project/dolfin"
MAIN_PV=$(ver_cut 1-3)
MYP=${PN}-${MAIN_PV}.post$(ver_cut 4)
SRC_URI="https://bitbucket.org/fenics-project/${PN}/downloads/${MYP}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~amd64-linux ~x86"
IUSE="mpi petsc slepc test"

# cmake is invoked by setup.py
BDEPEND="
	>=dev-util/cmake-3.5
	$(python_gen_cond_dep \
		'test? ( dev-python/pytest[${PYTHON_MULTI_USEDEP}] )')
	"

# Need headers from pybind11 to build the native parts, so not an RDEPEND
DEPEND="
	=sci-mathematics/dolfin-${MAIN_PV}*
	$(python_gen_cond_dep \
		'mpi? (
			>=dev-python/pybind11-2.2.3-r1[${PYTHON_MULTI_USEDEP}]
			dev-python/mpi4py[${PYTHON_MULTI_USEDEP}]
		)' \
		'petsc? ( dev-python/petsc4py[${PYTHON_MULTI_USEDEP}] )' \
		'slepc? ( dev-python/slepc4py[${PYTHON_MULTI_USEDEP}] )' \
	)
	"
# Depend on slot 0 ("mainline"), to forbid slot 'fd' (Firedrake fork)
RDEPEND="
	=dev-python/ffc-${MAIN_PV}*:0[${PYTHON_SINGLE_USEDEP}]
	=dev-python/fiat-${MAIN_PV}*:0[${PYTHON_SINGLE_USEDEP}]
	=dev-python/dijitso-${MAIN_PV}*:0[${PYTHON_SINGLE_USEDEP}]
	=dev-python/ufl-${MAIN_PV}*:0[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep \
		'dev-python/numpy[${PYTHON_MULTI_USEDEP}]' \
		'dev-python/pkgconfig[${PYTHON_MULTI_USEDEP}]' \
	)
	"

S="${WORKDIR}/${MYP}/python"

PATCHES=(
	"${FILESDIR}/${P}-verbose.patch"
	"${FILESDIR}/${P}-no-strip.patch"
)

src_unpack() {
	default
	# Delete all else (for meaningful dir size info, and reduce confusion)
	find "${MYP}" -not \( -path "${MYP}" \
		-o -path "${MYP}/python" -o -path "${MYP}/python/*" \) -delete
}

src_install() {
	distutils-r1_src_install --optimize=2
	# sci-mathematics/dolfin and dev-python/dolfin share doc dir, so rename
	find "${ED}"/usr/share/doc/${P} -name 'README.rst*' -delete
	newdoc README.rst README-py.rst
}
