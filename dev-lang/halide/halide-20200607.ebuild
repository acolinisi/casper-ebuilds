# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_8 )

inherit cmake python-single-r1

MY_PN=Halide
MY_COMMIT=a79da6e72827c32f6e295dd66aac982411cf2497

DESCRIPTION="A language for fast, portable data-parallel computation"
HOMEPAGE="https://halide-lang.org"
SRC_URI="https://github.com/halide/${MY_PN}/archive/${MY_COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~amd64-linux"

# subset of LLVM targets
MY_TARGETS=(AArch64 AMDGPU ARM Hexagon Mips
	NVPTX PowerPC RISCV WebAssembly X86)

function my_join_by { local IFS="$1"; shift; echo "$*"; }

MY_LLVM_TARGETS=("${MY_TARGETS[@]/#/llvm_targets_}")
MY_LLVM_TARGETS_FLAGS=$(my_join_by , "${MY_LLVM_TARGETS[@]/%/?}")

IUSE="doc examples opengl +openmp python tools test ${MY_LLVM_TARGETS[@]}"

DEPEND="
	>=sys-devel/llvm-9[bitwriter,lld,mcjit,passes,${MY_LLVM_TARGETS_FLAGS}]
	>=sys-devel/clang-9
	sys-libs/zlib
	media-libs/libpng
	virtual/jpeg
	opengl? ( virtual/opengl )
	python? ( dev-python/pybind11 )
	"

RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_PN}-${MY_COMMIT}"

PATCHES=(
	"${FILESDIR}"/${P}-cmake-opengl-opt.patch
	"${FILESDIR}"/${P}-cmake-openmp-opt.patch
	"${FILESDIR}"/${P}-cmake-llvm-fix-linking-against-LLVM-shared-lib.patch
	"${FILESDIR}"/${P}-cmake-pybind11.patch
)

src_configure() {
	# Halide build relies on -DNDEBUG flag being set by CMake, but
	# Gentoo cmake build type does not set it. When LLVM is built in
	# release mode, its headers are useable only with NDEBUG defined,
	# otherwise headers reference debug methods excluded from the lib.
	local build_type_flags="-DNDEBUG"
	local mycmakeargs+=(
		-DCMAKE_C_FLAGS="${CFLAGS} ${build_type_flags}"
		-DCMAKE_CXX_FLAGS="${CXXFLAGS} ${build_type_flags}"
		-DWITH_TESTS=$(usex test)
		-DWITH_TEST_ERROR=OFF
		-DWITH_PYTHON_BINDINGS=$(usex python)
		-DWITH_APPS=$(usex examples)
		-DWITH_TUTORIALS=$(usex examples)
		-DWITH_DOCS=$(usex doc)
		-DWITH_UTILS=$(usex tools)
		-DWITH_OPENGL=$(usex opengl)
		-DWITH_OPENMP=$(usex openmp)
		-DLLVM_USE_SHARED_LLVM_LIBRARY=ON
	)
	for target in ${MY_TARGETS[@]}; do
		mycmakeargs+=(-DWITH_${target^^}=$(usex llvm_targets_${target}))
	done
	cmake_src_configure
	#mkdir -p build && cd build
	#cmake -GNinja -DWITH_NVPTX=ON -DWITH_X86=ON -DCMAKE_BUILD_TYPE=Release ..
}

src_install() {
	# TODO: stuff gets installed into /usr/share/tools
	cmake_src_install
	mkdir -p ${ED}/usr/share/doc/${P}/
	mv ${ED}/usr/share/doc{,s}
	mv ${ED}/usr/share/{docs,tutorial,README_cmake.md} ${ED}/usr/share/doc/${P}/
	insinto /usr/share/${P}
	doins -r apps

	# internal headers
	insinto /usr/include/Halide
	doins src/*.h
}
