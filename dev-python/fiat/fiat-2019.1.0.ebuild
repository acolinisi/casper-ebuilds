# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_8 )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1

DESCRIPTION="FInite element Automatic Tabulator"
HOMEPAGE="https://bitbucket.org/fenics-project/fiat"
SRC_URI="https://bitbucket.org/fenics-project/fiat/downloads/${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~amd64-linux ~x86"
IUSE="test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="
	test? ( $(python_gen_cond_dep \
			'dev-python/pytest[${PYTHON_MULTI_USEDEP}]') )
	"
RDEPEND="${DEPEND}
	$(python_gen_cond_dep \
		'dev-python/numpy[${PYTHON_MULTI_USEDEP}]' \
		'dev-python/sympy[${PYTHON_MULTI_USEDEP}]' \
		)
	"
