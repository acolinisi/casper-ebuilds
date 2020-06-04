# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1

MY_PN=COFFEE

HOMEPAGE="https://github.com/coneoproject/COFFEE"
SRC_URI="https://github.com/coneoproject/${MY_PN}/archive/Firedrake_${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 ~amd64-linux"

S="${WORKDIR}/${MY_PN}-Firedrake_${PV}"

RDEPEND="
	$(python_gen_cond_dep \
	'
	dev-python/networkx[${PYTHON_MULTI_USEDEP}]
	dev-python/numpy[${PYTHON_MULTI_USEDEP}]
	dev-python/pulp[${PYTHON_MULTI_USEDEP}]
	dev-python/six[${PYTHON_MULTI_USEDEP}]
	')
	"
