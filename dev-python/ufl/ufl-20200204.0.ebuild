# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 eutils firedrake

DESCRIPTION="Unified Form Language for declaration of for FE discretizations (Firedrake fork)"
HOMEPAGE="https://github.com/firedrakeproject/ufl"
SRC_URI="https://github.com/firedrakeproject/${PN}/archive/Firedrake_${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3"
SLOT="fd" # as opposed to "mainline" (aka. FEniCS)
KEYWORDS="~amd64 ~x86"
IUSE="test"

S="${WORKDIR}/${PN}-Firedrake_${PV}"

DEPEND="
	test? ( $(python_gen_cond_dep \
			'dev-python/pytest[${PYTHON_MULTI_USEDEP}]') )
	"
RDEPEND="${DEPEND}
	$(python_gen_cond_dep \
		'dev-python/numpy[${PYTHON_MULTI_USEDEP}]' \
	)
	"

python_install_all()
{
	distutils-r1_python_install_all
	firedrake_install
}

pkg_postinst() {
	optfeature "Support for evaluating Bessel functions" sci-libs/scipy
}
