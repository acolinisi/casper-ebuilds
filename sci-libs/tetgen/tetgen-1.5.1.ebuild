# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

DESCRIPTION="Parallel mesh adaptation of #D volume meshes."
HOMEPAGE="http://wias-berlin.de/software/index.jsp?id=TetGen"
SRC_URI="${PN}${PV}.tar.gz"
RESTRICT="fetch" # requires submitting a web form

LICENSE="AGPL-3"
KEYWORDS="amd64 ~amd64-linux"
SLOT="0"
IUSE=""

S="${WORKDIR}/${PN}${PV}"

PATCHES=("${FILESDIR}"/${P}-shared-lib.patch)

src_install() {
	# Upstream cmake project does not provide an install target
	doheader tetgen.h
	pushd "${BUILD_DIR}"
	dolib.so libtet.so
	exeinto /usr/bin
	doexe tetgen
	popd
}
