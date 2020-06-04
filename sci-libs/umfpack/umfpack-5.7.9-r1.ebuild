# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

SUITESPARSE_VER=5.7.1
SUITESPARSE_COMP=UMFPACK

inherit suitesparse toolchain-funcs

DESCRIPTION="Unsymmetric multifrontal sparse LU factorization library"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~amd64-linux"
IUSE="cholmod"

BDEPEND="virtual/pkgconfig"
RDEPEND=">=sci-libs/suitesparseconfig-${SUITESPARSE_VER}
	>=sci-libs/amd-2.4.6-r1
	virtual/blas
	cholmod? ( =sci-libs/cholmod-3.0.14-r1 )"
DEPEND="${RDEPEND}"

PATCHES=("${FILESDIR}/${P}-version.patch")

src_compile() {
	suitesparse_src_compile \
		UMFPACK_CONFIG="$(usex cholmod "" "-DNCHOLMOD")" \
		BLAS="$($(tc-getPKG_CONFIG) --libs blas)"
}
