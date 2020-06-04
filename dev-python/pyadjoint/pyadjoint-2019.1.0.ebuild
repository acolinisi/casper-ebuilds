# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )

inherit distutils-r1 eutils

DESCRIPTION="The algorithmic differentation tool pyadjoint and add-ons."
HOMEPAGE="https://github.com/dolfin-adjoint/pyadjoint"
SRC_URI="https://github.com/dolfin-adjoint/${PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="test moola visualisation meshing"

# TODO: testing requires fenics (and, with HDF5)
DEPEND="
	test? ( dev-python/pytest[${PYTHON_USEDEP}] )
	"
# TODO: moola, meshio, pygmsh
RDEPEND="${DEPEND}
	>=sci-libs/scipy-1.0[${PYTHON_USEDEP}]
	moola? ( >=dev-python/moola-0.1.6 )
	visualisation? ( sci-libs/tensorflow
				>=dev-python/protobuf-python-3.6.0
				dev-python/networkx
				dev-python/pygraphviz )
	meshing? ( dev-python/pygmsh
			dev-python/meshio )
	"
distutils_enable_tests pytest
