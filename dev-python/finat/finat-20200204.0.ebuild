# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 firedrake

MY_PN=FInAT

DESCRIPTION="A more abstract, smarter library of finite elements (FInAT is not a tabulator)."
HOMEPAGE="https://github.com/FInAT/FInAT"
SRC_URI="https://github.com/FInAT/${MY_PN}/archive/Firedrake_${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="fd"
KEYWORDS="amd64 ~amd64-linux"

MY_FV=$(ver_cut 1)

S="${WORKDIR}/${MY_PN}-Firedrake_${PV}"

# TODO: tsfc circular dep (use PDEPEND? doesn't help with testing)
# TODO: testing requires gem from tsfc
RDEPEND="
	=dev-python/fiat-${MY_FV}*:fd[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep \
		'>=dev-python/numpy-1.6.1[${PYTHON_MULTI_USEDEP}]')
	"

distutils_enable_tests pytest

python_install_all()
{
	distutils-r1_python_install_all
	firedrake_install
}
