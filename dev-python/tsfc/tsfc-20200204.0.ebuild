# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 firedrake

DESCRIPTION="Two-stage form compiler for Finite Element Method"
HOMEPAGE="https://github.com/firedrakeproject/tsfc"
SRC_URI="https://github.com/firedrakeproject/${PN}/archive/Firedrake_${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL"

# Even if this package itself is not forked, as long as as it depends on an
# 'fd' slot (i.e. Firedrake's fork) of a dependency, this package is also
# quarantined into 'fd' slot as well. If/when Firedrake merges the fork into
# upstream, we can change to SLOT=0 here.
SLOT="fd"

KEYWORDS="amd64 ~amd64-linux"

MY_FV=$(ver_cut 1)

S="${WORKDIR}/${PN}-Firedrake_${PV}"

RDEPEND="
	=dev-python/coffee-${MY_FV}*[${PYTHON_SINGLE_USEDEP}]
	=dev-python/fiat-${MY_FV}*:fd[${PYTHON_SINGLE_USEDEP}]
	=dev-python/finat-${MY_FV}*:fd[${PYTHON_SINGLE_USEDEP}]
	=dev-python/loopy-${MY_FV}*:fd[${PYTHON_SINGLE_USEDEP}]
	=dev-python/ufl-${MY_FV}*:fd[${PYTHON_SINGLE_USEDEP}]
	$(python_gen_cond_dep \
		'dev-python/numpy[${PYTHON_MULTI_USEDEP}]')
	"

distutils_enable_tests pytest

python_install_all()
{
	distutils-r1_python_install_all
	firedrake_install
}
