# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 firedrake

DESCRIPTION="FInite element Automatic Tabulator (Firedrake fork)"
HOMEPAGE="https://github.com/firedrakeproject/fiat"
SRC_URI="https://github.com/firedrakeproject/${PN}/archive/Firedrake_${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="fd"
KEYWORDS="~amd64 ~amd64-linux ~x86"
IUSE="test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

S="${WORKDIR}/${PN}-Firedrake_${PV}"

BDEPEND="
	test? ( $(python_gen_cond_dep \
			'dev-python/pytest[${PYTHON_MULTI_USEDEP}]') )
	"
RDEPEND="
	$(python_gen_cond_dep \
		'dev-python/numpy[${PYTHON_MULTI_USEDEP}]' \
		'dev-python/sympy[${PYTHON_MULTI_USEDEP}]' \
		)
	"
python_install_all()
{
	distutils-r1_python_install_all
	firedrake_install
}
