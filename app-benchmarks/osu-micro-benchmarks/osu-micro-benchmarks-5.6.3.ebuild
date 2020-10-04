# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="OSU Micro-Benchmarks for MPI, OpenSHMEM, UPC, UPC++"
HOMEPAGE="https://mvapich.cse.ohio-state.edu/benchmarks/"
SRC_URI="https://mvapich.cse.ohio-state.edu/download/mvapich/${P}.tar.gz"

SLOT="0"
LICENSE="BSD"
KEYWORDS="~amd64 ~amd64-linux"
IUSE="cuda openacc"

# TODO: OpenACC deps?
RDEPEND="cuda? ( dev-util/nvidia-cuda-toolkit )"
DEPEND="${RDEPEND}"

PATCHES=()

src_configure() {
	CC=mpicc CXX=mpicxx econf \
		$(use_enable cuda) \
		$(use_enable openacc)
}

src_install() {
	default
	dobin "${FILESDIR}"/osubench
	sed -i -e "s:@__PREFIX__@:$EPREFIX:g" $ED/usr/bin/osubench
}
