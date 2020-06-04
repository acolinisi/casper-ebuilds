# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )

inherit distutils-r1

DESCRIPTION="Generate and execute native code at run time."
HOMEPAGE="http://mathema.tician.de/software/codepy
		http://pypi.python.org/pypi/codepy"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${PN}-${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~amd64-linux"

RDEPEND="${DEPEND}
	>=dev-python/appdirs-1.4.0[${PYTHON_USEDEP}]
	dev-python/cgen[${PYTHON_USEDEP}]
	>=dev-python/numpy-1.6[${PYTHON_USEDEP}]
	>=dev-python/pytools-2015.1.2[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]
	"

distutils_enable_tests pytest

#python_test()
#{
	#pushd test/unit
	#pytest || die
	#popd
#}
