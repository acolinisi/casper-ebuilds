# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )

inherit distutils-r1

DESCRIPTION="Random generator supporting multiple PRNGs"
HOMEPAGE="https://github.com/bashtage/randomgen"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="NCSA"
SLOT="0"
KEYWORDS="amd64 ~amd64-linux"
IUSE="doc"

#TODO:	dev-python/sphinx-material[${PYTHON_USEDEP}]
# TODO: setup.py:38: UserWarning: Unable to import pypandoc.  Do not use this as a release build!
BDEPEND="
	doc? ( >=dev-python/sphinx-1.8[${PYTHON_USEDEP}] )
	>=dev-python/pytest-4[${PYTHON_USEDEP}]
	"
# need numpy headers at compile time
DEPEND="
	>=dev-python/cython-0.26[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.13[${PYTHON_USEDEP}]
	"

distutils_enable_tests pytest

# even with install does not work
python_test() {
	distutils_install_for_testing
	pytest -vv || die
}
