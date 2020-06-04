# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

SUITESPARSE_VER=5.7.1
SUITESPARSE_COMP=SuiteSparse_GPURuntime

inherit cuda suitesparse toolchain-funcs

DESCRIPTION="Helper functions for the GPU"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~amd64-linux"
IUSE=""

RDEPEND=">=sci-libs/suitesparseconfig-${SUITESPARSE_VER}
	dev-util/nvidia-cuda-toolkit
"
DEPEND="${RDEPEND}"

src_prepare() {
	suitesparse_src_prepare
	cuda_src_prepare
}

src_install() {
	suitesparse_src_install
	doheader Include/*
}
