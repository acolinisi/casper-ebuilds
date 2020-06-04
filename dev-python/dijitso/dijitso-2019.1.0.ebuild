# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1

DESCRIPTION="Python module for distributed just-in-time shared library building"
HOMEPAGE="https://bitbucket.org/fenics-project/dijitso/"
SRC_URI="https://bitbucket.org/fenics-project/dijitso/downloads/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~amd64-linux ~x86"
IUSE="test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

BDEPEND="
	test? ( $(python_gen_cond_dep \
			'dev-python/pytest[${PYTHON_MULTI_USEDEP}]') )
	"
# note: mpi4py undeclared in setup.py but used
RDEPEND="${PYTHON_DEPS}
	$(python_gen_cond_dep \
		'dev-python/mpi4py[${PYTHON_MULTI_USEDEP}]' \
		'dev-python/numpy[${PYTHON_MULTI_USEDEP}]' \
	)
	"

PATCHES=("${FILESDIR}/${P}-uncompress-man.patch")

python_prepare() {
	# upstream ships compressed man pages in the tarball
	gzip -d doc/man/*/*.gz
}
