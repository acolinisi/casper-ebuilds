# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

FORTRAN_STANDARD=77

inherit cmake fortran-2

MY_PN=SuperLU

if [[ ${PV} != *9999* ]]; then
	SRC_URI="https://crd-legacy.lbl.gov/~xiaoye/SuperLU//${PN}_${PV}.tar.gz"
	KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~ia64 ~ppc ppc64 ~sparc x86 ~amd64-linux ~x86-linux"
	SLOT="0/$(ver_cut 1)"
	S="${WORKDIR}/SuperLU_${PV}"
else
	inherit git-r3
	GIT_ECLASS="git-r3"
	EGIT_REPO_URI="https://github.com/xiaoyeli/${PN}"
	SLOT="0/9999"
	KEYWORDS="amd64 ~arm64 ~hppa ~ia64 ppc64 ~sparc x86"
fi

DESCRIPTION="Sparse LU factorization library"
HOMEPAGE="https://crd-legacy.lbl.gov/~xiaoye/SuperLU/"
LICENSE="BSD"

IUSE="doc examples test"
RESTRICT="!test? ( test )"

RDEPEND="virtual/blas"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	test? ( app-shells/tcsh )"

PATCHES=(
	"${FILESDIR}"/${P}-no-implicits.patch
	"${FILESDIR}"/${P}-pkgconfig.patch
)

S="${WORKDIR}/${MY_PN}_${PV}"

src_prepare() {
	cmake_src_prepare
	# respect user's CFLAGS
	sed -i -e 's/O3//' CMakeLists.txt || die
}

src_configure() {
	local mycmakeargs+=(
		-DCMAKE_INSTALL_INCLUDEDIR="include/${PN}"
		-DBUILD_SHARED_LIBS=ON
		-Denable_blaslib=OFF
		-Denable_tests=$(usex test)
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
	use doc && dodoc -r DOC/html
	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r EXAMPLE FORTRAN
		docompress -x /usr/share/doc/${PF}/examples
	fi
}
