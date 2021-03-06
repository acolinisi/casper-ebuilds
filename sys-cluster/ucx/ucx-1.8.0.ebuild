# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Unified Communication X"
HOMEPAGE="http://www.openucx.org"
SRC_URI="https://github.com/openucx/ucx/releases/download/v${PV}/${P}.tar.gz"

# subslotted because openmpi needs to be rebuilt when UCX minor changes
SLOT="0/$(ver_cut 1-2)"
LICENSE="BSD"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE="+numa +openmp"

RDEPEND="
	sys-libs/binutils-libs:=
	numa? ( sys-process/numactl )
"
DEPEND="${RDEPEND}"

PATCHES=(
	"${FILESDIR}"/${P}-binutils2.34-macros.patch
)

src_configure() {
	BASE_CFLAGS="" \
	econf \
		--disable-compiler-opt \
		$(use_enable numa) \
		$(use_enable openmp)
}

src_compile() {
	BASE_CFLAGS="" emake
}
