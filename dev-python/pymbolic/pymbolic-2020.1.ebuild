# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )

inherit distutils-r1

DESCRIPTION="A small expression tree and symbolic manipulation library."
HOMEPAGE="http://mathema.tician.de/software/pymbolic
		http://pypi.python.org/pypi/pymbolic"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${PN}-${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~amd64-linux"

# TODO: upstream lists pytest in install_requires
RDEPEND="${DEPEND}
	dev-python/pytest[${PYTHON_USEDEP}]
	>=dev-python/pytools-2[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]
	"
