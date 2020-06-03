# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

MY_PV=$(ver_rs 3 -)

DESCRIPTION="Parallel mesh adaptation of #D volume meshes."
HOMEPAGE="http://wias-berlin.de/software/index.jsp?id=TetGen"
SRC_URI="${PN}${MY_PV}.tar.gz"
RESTRICT="fetch" # requires submitting a web form

LICENSE="AGPL-3"
KEYWORDS="amd64 ~amd64-linux"
SLOT="0"
IUSE=""

S="${WORKDIR}/${PN}${MY_PV}"

PATCHES=("${FILESDIR}"/${PN}-1.5.1-shared-lib.patch)

src_unpack() {
	# Upstream compressed twice...
	gzip -d "${DISTDIR}"/${A} -c > "${DISTDIR}"/${P}.tgz
	unpack ${P}.tgz
}

src_configure() {
	local mycmakeargs=(
		-DCMAKE_C_FLAGS="${CFLAGS} -fPIC"
		-DCMAKE_CXX_FLAGS="${CXXFLAGS} -fPIC"
	)
	cmake_src_configure
}

src_install() {
	# Upstream cmake project does not provide an install target
	doheader tetgen.h
	pushd "${BUILD_DIR}"
	dolib.so libtet.so
	exeinto /usr/bin
	doexe tetgen
	popd
}
