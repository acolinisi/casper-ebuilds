# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )

inherit distutils-r1

MY_PN=PuLP

HOMEPAGE="https://coin-or.github.io/pulp/"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_PN}-${PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 ~amd64-linux"

S="${WORKDIR}/${MY_PN}-${PV}"

# TODO: check whether solver needed at build (DEPEND)
RDEPEND="${DEPEND}
	|| ( sci-libs/coinor-cbc
		sci-mathematics/glpk )
	>=dev-python/pyparsing-2.0.1[${PYTHON_USEDEP}]
	"
# _cplex: http://cplex.com
# _gurobi: http://gurobi.com

# TODO: test (see if can run testsuite on built not installed)
# import pulp.tests.run_tests
# pulp.tests.run_tests.pulpTestAll()
