# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs

MY_PN=BemTool
MY_COMMIT=c608875aca175b3bb424c50a9c13131aa7e2b257

DESCRIPTION="BemTool is a C++ boundary element library."
HOMEPAGE="https://github.com/PierreMarchand20/BemTool
			https://github.com/xclaeys/BemTool
			https://www.ljll.math.upmc.fr/~claeys/"
# Using same source as used by FreeFEM++
SRC_URI="https://github.com//PierreMarchand20/${MY_PN}/archive/${MY_COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-3"
KEYWORDS="amd64 ~amd64-linux"
SLOT="0/${PV}" # header-only library, so rebuild on all changes
IUSE="test"

# header-only library, so deps do not need to be preinstalled unless test
MY_DEPEND="
	virtual/mpi
	>=dev-cpp/eigen-3
	dev-libs/boost
	"
BDEPEND="test? ( ${MY_DEPEND} )"
RDEPEND="${MY_DEPEND}"
DEPEND=""

S="${WORKDIR}"/${MY_PN}-${MY_COMMIT}

PATCHES=(
	"${FILESDIR}"/${P}-test-include.patch
	)

MY_TESTS=(test2D) # test2D: 5mins, test3D: ~1.25 hour

src_compile() {
	if use test; then
		emake "${MY_TESTS[@]}" \
			GCC="mpic++ ${CXXFLAGS}" \
			INCLUDE="-Ibemtool $($(tc-getPKG_CONFIG) --cflags eigen3)"
	fi
}

src_test() {
	for t in "${MY_TESTS[@]}"; do
		./${t} || die
	done
}

src_install() {
	doheader -r bemtool
	dodoc doc/*.pdf
}

pkg_postinst() {
	optfeature "Generate meshes from Gmsh specs output by ${PN}" sci-libs/gmsh
}
