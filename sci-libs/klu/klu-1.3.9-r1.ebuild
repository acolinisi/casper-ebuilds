# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

SUITESPARSE_VER=5.7.1
SUITESPARSE_COMP=KLU

inherit suitesparse

DESCRIPTION="Sparse LU factorization for circuit simulation"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64 ~amd64-linux"
# TODO: demo

DEPEND="
	>=sci-libs/suitesparseconfig-${SUITESPARSE_VER}
	>=sci-libs/amd-2.4.6-r1
	>=sci-libs/btf-1.2.6-r1
	>=sci-libs/colamd-2.9.6-r1"
RDEPEND="${DEPEND}"
