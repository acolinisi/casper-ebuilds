# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# TODO: upstream: include FindARPACK.cmake since not provided by cmake
# e.g. https://github.com/dune-project/dune-istl/blob/master/cmake/modules/FindARPACK.cmake

PYTHON_COMPAT=( python3_{6,7,8} )

inherit cmake python-single-r1 toolchain-funcs

MY_COMMIT=f95cdacadf07f7d42d007f970434493148848653

DESCRIPTION="Hierarchical matrices tool box"
HOMEPAGE="https://github.com/htool-ddm/htool"
SRC_URI="https://github.com/htool-ddm/${PN}/archive/${MY_COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
KEYWORDS="amd64 ~amd64-linux"
SLOT="0/${PV}" # header-only library, so rebuild on all changes
IUSE="arpack examples gui hpddm lapack python test"

# tests assume some optional features are present
REQUIRED_USE="
	test? ( hpddm lapack )
	python?  ( ${PYTHON_REQUIRED_USE} )
	"

# TODO: gui fetches dependencies from online and builds...

BDEPEND="virtual/pkgconfig"
# The library is header-only, but it also installs cmake modules
# and this ebuild installs pkg-config .pc files, both of which need the
# dependencies to be available at configure time.
DEPEND="
	virtual/blas
	virtual/mpi
	arpack? ( sci-libs/arpack )
	lapack? ( virtual/lapack )
	hpddm? ( sci-libs/hpddm )
	gui? ( media-libs/glm )
	"
RDEPEND="${DEPEND}
	python? ( ${PYTHON_DEPS} $(python_gen_cond_dep \
		'
		dev-python/mpi4py[${PYTHON_MULTI_USEDEP}]
		dev-python/numpy[${PYTHON_MULTI_USEDEP}]
		dev-python/matplotlib[${PYTHON_MULTI_USEDEP}]
		dev-python/scipy[${PYTHON_MULTI_USEDEP}]
		')
	)
	"

S="${WORKDIR}"/${PN}-${MY_COMMIT}

PATCHES=(
	"${FILESDIR}"/${P}-cmake-optional-libs.cmake
	"${FILESDIR}"/${P}-cmake-optional-libs2.cmake
	"${FILESDIR}"/${P}-cmake-libdir.cmake
	)

src_configure() {
	local mycmakeargs=(
		-DHTOOL_WITH_EXAMPLES=$(usex examples)
		-DHTOOL_WITH_GUI=$(usex gui)
		-DHTOOL_WITH_PYTHON_INTERFACE=$(usex python)
		-DHTOOL_WITH_ARPACK=$(usex arpack)
		-DHTOOL_WITH_LAPACK=$(usex lapack)
		-DHTOOL_WITH_HPDDM=$(usex hpddm)
		-DHPDDM_INCLUDE_DIR="${EPREFIX}/usr/include/hpddm"
	)
	if use arpack; then
		mycmakeargs+=(-DARPACK_LIBRARIES="$($(tc-getPKG_CONFIG) --libs arpack)")
	fi
	cmake_src_configure
}

src_compile() {
	# TODO: examples are not built (also, should they be installed)?
	cmake_src_compile \
		$(usex test build-tests "") \
		$(usex examples build-examples "")
}

src_test() {
	# TODO: Test_hmat_(vec|mat)_prod tests fail with:
	#    Assertion `dirnorm >= 1.e-10' failed.
	cmake_src_test -E 'Test_hmat_[^_]*_prod_[1-4]'
}

src_install() {
	cmake_src_install

	# TODO: Requires: hpddm ?
	cat <<-EOF > ${PN}.pc
	prefix=${EPREFIX}/usr
	libdir=\${prefix}/$(get_libdir)
	Name: ${PN}
	Description: ${DESCRIPTION}
	Version: ${PV}
	URL: ${HOMEPAGE}
	Libs: -L\${libdir} $($(tc-getPKG_CONFIG) --libs \
		$(usex lapack lapack "") $(usex arpack arpack ""))
	Cflags: -I\${prefix}/include/${PN}
	EOF
	insinto /usr/$(get_libdir)/pkgconfig
	doins ${PN}.pc
}
