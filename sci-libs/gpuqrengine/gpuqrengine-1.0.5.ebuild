# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

SUITESPARSE_VER=5.7.1
SUITESPARSE_COMP=GPUQREngine

inherit cuda suitesparse toolchain-funcs

DESCRIPTION="A GPU-accelerated QR factorization engine"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~amd64-linux"
IUSE=""

RDEPEND="
	>=sci-libs/suitesparseconfig-${SUITESPARSE_VER}
	sci-libs/suitesparse-gpuruntime
	"
DEPEND="${RDEPEND}"

src_prepare() {
	suitesparse_src_prepare
	cuda_src_prepare
}

src_compile() {
	# H3 adds GPURuntime headers to prereqs, which is unnecessary
	suitesparse_src_compile H3=
}

src_install() {
	suitesparse_src_install
	doheader Include/*.hpp
}
