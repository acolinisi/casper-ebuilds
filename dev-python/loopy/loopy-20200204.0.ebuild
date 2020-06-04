# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 firedrake

MY_PN=loo.py

DESCRIPTION="A code generator for array-based code on CPUs and GPUs (Firedrake fork)"
HOMEPAGE="https://mathema.tician.de/software/loopy/
		https://github.com/firedrakeproject/loopy
		https://github.com/inducer/loopy
	"
# Upstream includes a submodule that is not packaged for installation,
# and whose source must be in a subdirectory in the source tree.
# To get the commit, look at loopy/loopy/target/c/compyte
COMPBYTE_COMMIT=25ee8b48fd0c7d9f0bd987c6862cdb1884fb1372
SRC_URI="https://github.com/firedrakeproject/${PN}/archive/Firedrake_${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/inducer/compyte/archive/${COMPBYTE_COMMIT}.zip -> compyte-${COMPBYTE_COMMIT}.zip
	"

S="${WORKDIR}/${PN}-Firedrake_${PV}"

LICENSE="MIT"
SLOT="fd"
KEYWORDS="amd64 ~amd64-linux"
IUSE="opencl fortran"

# Tests don't treat pyopencl as optional
REQUIRED_USE="test? ( opencl )"

# TODO: fortran deps
# TODO: upstream says !>=dev-python/cgen-2019.1[${PYTHON_USEDEP}]
# TODO: testing assumes pyopencl
RDEPEND="${DEPEND}
	$(python_gen_cond_dep \
	'
	>=dev-python/cgen-2016.1[${PYTHON_MULTI_USEDEP}]
	>=dev-python/codepy-2017.1[${PYTHON_MULTI_USEDEP}]
	dev-python/colorama[${PYTHON_MULTI_USEDEP}]
	>=dev-python/genpy-2016.1.2[${PYTHON_MULTI_USEDEP}]
	dev-python/mako[${PYTHON_MULTI_USEDEP}]
	>=dev-python/islpy-2019.1[${PYTHON_MULTI_USEDEP}]
	dev-python/numpy[${PYTHON_MULTI_USEDEP}]
	>=dev-python/pytools-2018.4[${PYTHON_MULTI_USEDEP}]
	>=dev-python/pymbolic-2019.2[${PYTHON_MULTI_USEDEP}]
	>=dev-python/six-1.8.0[${PYTHON_MULTI_USEDEP}]
	opencl? ( >=dev-python/pyopencl-2015.2[${PYTHON_MULTI_USEDEP}] )
	fortran? ( >=dev-python/f2py-0.3.1[${PYTHON_MULTI_USEDEP}]
			>=dev-python/ply-3.6[${PYTHON_MULTI_USEDEP}] )
	')
	"

distutils_enable_tests pytest

src_unpack() {
	default
	unpack compyte-${COMPBYTE_COMMIT}.zip
	rmdir ${S}/loopy/target/c/compyte
	mv compyte-${COMPBYTE_COMMIT} ${S}/loopy/target/c/compyte
}

python_install_all()
{
	distutils-r1_python_install_all
	firedrake_install
}
