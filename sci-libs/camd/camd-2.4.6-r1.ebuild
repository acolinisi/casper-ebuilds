# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

SUITESPARSE_VER=5.7.1
SUITESPARSE_COMP=CAMD

inherit suitesparse

DESCRIPTION="Library to order a sparse matrix prior to Cholesky factorization"

LICENSE="BSD"
SLOT="0"

KEYWORDS="~amd64 ~amd64-linux"
# TODO: demo

DEPEND=">=sci-libs/suitesparseconfig-${SUITESPARSE_VER}"
RDEPEND="${DEPEND}"
