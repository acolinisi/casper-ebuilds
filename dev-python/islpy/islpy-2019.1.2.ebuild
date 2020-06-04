# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )

inherit distutils-r1

DESCRIPTION="A code generator for array-based code on CPUs and GPUs"
HOMEPAGE="https://documen.tician.de/islpy/
		http://pypi.python.org/pypi/islpy"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${PN}-${PV}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~amd64-linux"
# TODO: barvinok: http://barvinok.gforge.inria.fr/
IUSE="jit"

DEPEND="
	dev-libs/isl
	"
# TODO: upstream lists pytest in install_requires
RDEPEND="${DEPEND}
	>=dev-python/cffi-1.1.0[${PYTHON_USEDEP}]
	dev-python/pytest[${PYTHON_USEDEP}]
	dev-python/six[${PYTHON_USEDEP}]
	"

PATCHES=("${FILESDIR}/${P}-isl-0.22.patch")

python_configure() {
	./configure.py \
		--no-use-shipped-isl \
		--no-use-shipped-imath \
		--isl-inc-dir="${EPREFIX}/usr/include" \
		--isl-lib-dir="${EPREFIX}/usr/$(get_libdir)"
}
