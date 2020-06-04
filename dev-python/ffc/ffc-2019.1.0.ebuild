# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1

DESCRIPTION="Compiler for multilinear forms by generating C or C++ code"
HOMEPAGE="https://bitbucket.org/fenics-project/ffc/"
SRC_URI="https://bitbucket.org/fenics-project/ffc/downloads/${P}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~amd64-linux ~x86"
IUSE="test"

MAIN_PV=$(ver_cut 1-3)

DEPEND="test? ( $(python_gen_cond_dep \
			'dev-python/pytest[${PYTHON_MULTI_USEDEP}]') )
	"
# Depend on slot 0 ("mainline"), to forbid slot 'fd' (Firedrake fork)
RDEPEND="${DEPEND}
	!sci-mathematics/ufc
	=dev-python/fiat-${MAIN_PV}*:0[${PYTHON_SINGLE_USEDEP}]
	=dev-python/dijitso-${MAIN_PV}*:0[${PYTHON_SINGLE_USEDEP}]
	=dev-python/ufl-${MAIN_PV}*:0[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep 'dev-python/numpy[${PYTHON_MULTI_USEDEP}]')
	"
