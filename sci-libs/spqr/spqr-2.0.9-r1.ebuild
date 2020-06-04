# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

SUITESPARSE_VER=5.7.1
SUITESPARSE_COMP=SPQR
SUITESPARSE_DEPS="GPUQREngine SuiteSparse_GPURuntime"

inherit cuda suitesparse toolchain-funcs

DESCRIPTION="Multithreaded multifrontal sparse QR factorization library"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~amd64-linux"
IUSE="cuda partition expert timing tbb"

# We require the cholmod supernodal module that is enabled with
# USE=lapack, and cholmod has to have partition support if spqr is going
# to have it. Note that spqr links to metis directly, too.
DEPEND=">=sci-libs/suitesparseconfig-${SUITESPARSE_VER}
	virtual/blas
	virtual/lapack
	>=sci-libs/cholmod-3.0.14-r1[partition?]
	cuda? ( sci-libs/gpuqrengine )
	partition? ( || ( >=sci-libs/metis-5.1.0 sci-libs/parmetis ) )
	tbb? ( dev-cpp/tbb )"
RDEPEND="${DEPEND}"

src_prepare() {
	suitesparse_src_prepare
	cuda_src_prepare
}

my_src_compile() {
	local CONFIG_PARTITION=""
	local SPQR_CONFIG=(
		$(usex partition "" "-DNPARTITION -DNCAMD")
		$(usex expert "" " -DNEXPERT ")
		$(usex tbb " -DHAVE_TBB " "")
		$(usex timing " -DTIMING " "")
	)
	suitesparse_src_compile SPQR_CONFIG="${SPQR_CONFIG[@]}" \
		BLAS="$($(tc-getPKG_CONFIG) --libs blas)" \
		LAPACK="$($(tc-getPKG_CONFIG) --libs lapack)" \
		CUDA=$(usex cuda auto no)
}

src_compile()
{
	if use cuda; then
		cuda_with_gcc my_src_compile
	else
		my_src_compile
	fi
}
