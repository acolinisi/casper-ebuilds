# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )

inherit cmake python-r1

DESCRIPTION="AST-based Python refactoring library"
HOMEPAGE="https://github.com/pybind/pybind11"
SRC_URI="https://github.com/pybind/${PN}/archive/v${PV}.tar.gz -> ${P}-full.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc ~ppc64 ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="test"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

# Some (optional) tests need dev-python/scipy, but that'd be a circular dep
DEPEND="${PYTHON_DEPS}
	test? (
		>=dev-cpp/catch-1.9.3
		dev-cpp/eigen
		>=dev-libs/boost-1.56
		dev-python/pytest[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		)
	"

src_configure() {
	local mycmakeargs=(
		-DPYBIND11_INSTALL=ON
		-DPYBIND11_TEST=$(usex test)
	)
	if use test; then
		mycmakeargs+=(-DCATCH_INCLUDE_DIR="${EPREFIX}/usr/include/catch2")
	fi
	python_foreach_impl run_in_build_dir cmake_src_configure
}

src_compile() {
	python_foreach_impl run_in_build_dir cmake_src_compile
	python_foreach_impl python setup.py build
}

src_test() {
	python_foreach_impl run_in_build_dir ninja pytest
}

src_install() {
	# Installed artifacts are not specific to python version, only tests are,
	# so this will overwrite, but it's harmless and simplest code here.
	python_foreach_impl run_in_build_dir cmake_src_install
	python_foreach_impl python setup.py install
}
