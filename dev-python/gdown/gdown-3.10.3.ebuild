# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )

inherit distutils-r1

DESCRIPTION="Download a large file from Google Drive."
HOMEPAGE="
	https://pypi.org/project/gdown/
	https://github.com/wkentaro/gdown
	"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

SLOT="0"
LICENSE="public-domain"
KEYWORDS="~alpha amd64 ~arm arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ppc64 ~s390 ~sparc x86 ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="
	dev-python/requests[${PYTHON_USEDEP},socks5]
	dev-python/six[${PYTHON_USEDEP}]
	dev-python/tqdm[${PYTHON_USEDEP}]
	dev-python/filelock[${PYTHON_USEDEP}]
	"
DEPEND="${RDEPEND}"
