# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )

inherit cmake python-single-r1 fortran-2

DESCRIPTION="Non-linear optimization library"
HOMEPAGE="
	http://ab-initio.mit.edu/nlopt/
	https://nlopt.readthedocs.io/en/latest/
	https://github.com/stevengj/nlopt
	"
SRC_URI="https://github.com/stevengj/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2.1 MIT"
KEYWORDS="amd64 x86 ~amd64-linux ~x86-linux"
SLOT="0"
IUSE="cxx fortran guile octave python test"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"

DEPEND="
	guile? (
		dev-lang/swig
		dev-scheme/guile:*
		)
	octave? ( sci-mathematics/octave )
	python? (
		dev-lang/swig
		${PYTHON_DEPS}
		$(python_gen_cond_dep \
			'dev-python/numpy[${PYTHON_MULTI_USEDEP}]')
		)
	"
RDEPEND="${DEPEND}"

PATCHES=("${FILESDIR}"/${P}-pkg-config-libdir.patch)

src_configure() {
	local test_fortran=OFF
	if use test && use fortran; then
		test_fortran=ON
	fi
	local use_swig=OFF
	if use guile || use python; then
		use_swig=ON
	fi
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON
		-DNLOPT_CXX=$(usex cxx)
		-DNLOPT_FORTRAN=${test_fortran}
		-DNLOPT_GUILE=$(usex guile)
		-DNLOPT_MATLAB=OFF
		-DNLOPT_OCTAVE=$(usex octave)
		-DNLOPT_PYTHON=$(usex python)
		-DNLOPT_SWIG=${use_swig}
		-DNLOPT_TESTS=$(usex test)
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
	use python && python_setup && python_optimize
}
