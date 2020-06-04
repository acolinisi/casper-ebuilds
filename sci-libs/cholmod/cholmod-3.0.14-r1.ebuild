# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

SUITESPARSE_VER=5.7.1
SUITESPARSE_COMP=CHOLMOD

inherit cuda suitesparse toolchain-funcs

DESCRIPTION="Sparse Cholesky factorization and update/downdate library"

LICENSE="LGPL-2.1+"
SLOT="0"
KEYWORDS="~amd64 ~amd64-linux"
IUSE="cuda +partition"

BDEPEND="virtual/pkgconfig"
DEPEND=">=sci-libs/suitesparseconfig-${SUITESPARSE_VER}
	>=sci-libs/amd-2.4.6-r1
	>=sci-libs/colamd-2.9.6-r1
	virtual/blas
	virtual/lapack
	cuda? ( x11-drivers/nvidia-drivers dev-util/nvidia-cuda-toolkit )
	partition? (
		>=sci-libs/camd-2.4.6-r1
		>=sci-libs/ccolamd-2.9.6-r1
		|| ( >=sci-libs/metis-5.1.0 sci-libs/parmetis ) )"
RDEPEND="${DEPEND}"

my_src_compile() {
	local CONFIG_PARTITION="$(usex partition "" "-DNPARTITION -DNCAMD")"
	suitesparse_src_compile \
		BLAS="$($(tc-getPKG_CONFIG) --libs blas)" \
		LAPACK="$($(tc-getPKG_CONFIG) --libs lapack)" \
		CUDA=$(usex cuda auto no) \
		CHOLMOD_CONFIG="${CONFIG_PARTITION}" \
		CONFIG_PARTITION="${CONFIG_PARTITION}" \
		LIB_WITH_PARTITION="$(usex partition "-lccolamd -lcamd -lmetis" "")"
}

src_compile() {
	if use cuda; then
		cuda_with_gcc my_src_compile
	else
		my_src_compile
	fi
}
