# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

SUITESPARSE_VER=5.7.1
SUITESPARSE_COMP=AMD

inherit fortran-2 suitesparse

DESCRIPTION="Library to order a sparse matrix prior to Cholesky factorization"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~amd64-linux"
# TODO: demo
IUSE="fortran"

DEPEND=">=sci-libs/suitesparseconfig-${SUITESPARSE_VER}"
RDEPEND="${DEPEND}"

PATCHES=("${FILESDIR}"/${P}-test-target.patch)

src_compile() {
	suitesparse_src_compile $(usev fortran)
}

src_install() {
	suitesparse_src_install

	if use static-libs && use fortran; then
		dolib.a Lib/lib${PN}f77.a
	fi
	# UMFPACK needs it...
	doheader Include/amd_internal.h
}
