# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )

inherit distutils-r1

MY_PN=loo.py

DESCRIPTION="A code generator for array-based code on CPUs and GPUs"
HOMEPAGE="https://mathema.tician.de/software/loopy/
		http://pypi.python.org/pypi/loo.py"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_PN}-${PV}.tar.gz"

S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~amd64-linux"
IUSE="jit"

RDEPEND="${DEPEND}
	dev-python/numpy[${PYTHON_USEDEP}]
	dev-python/islpy[${PYTHON_USEDEP}]
	jit? ( dev-python/pyopencl[${PYTHON_USEDEP}] )
	"
