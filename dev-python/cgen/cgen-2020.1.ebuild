# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )

inherit distutils-r1

DESCRIPTION="C/C++ source generation from an AST"
HOMEPAGE="http://documen.tician.de/cgen/
		http://pypi.python.org/pypi/cgen"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${PN}-${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~amd64-linux"

RDEPEND="${DEPEND}
	>=dev-python/numpy-1.6[${PYTHON_USEDEP}]
	dev-python/pytools[${PYTHON_USEDEP}]
	"
