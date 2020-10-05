# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake fortran-2

# firedrake needs libsupermesh-c.h, which is not yet released;
# also, release vendors dependency, so grab a branch where this is fixed.
# branch: external_libspatialindex
MY_COMMIT=4f0be8a9b6eb

DESCRIPTION="Parallel supermeshing library"
HOMEPAGE="https://bitbucket.org/libsupermesh/libsupermesh"
SRC_URI="https://bitbucket.org/libsupermesh/${PN}/get/${MY_COMMIT}.tar.bz2 -> ${P}.tar.bz2"

S="${WORKDIR}/libsupermesh-${PN}-${MY_COMMIT}"

SLOT="0"
LICENSE="LGPL-2.1"
KEYWORDS="~amd64 ~amd64-linux"
# TODO: rename to double-precision (or rename to double in sci-libs/parmetis)
IUSE="doc +judy timers overlap_comms +double test"

# does not compile with libspatialindex 1.9.3
DEPEND=">=virtual/mpi-2
	<sci-libs/libspatialindex-1.9
	doc? ( virtual/latex-base )
	judy? ( dev-libs/judy )
	"

PATCHES=(
	"${FILESDIR}/${P}-cmake-lib.patch"
	"${FILESDIR}/${PN}-1.0.1-cxx11.patch"
	"${FILESDIR}/${P}-mpi-get-extent.patch"
	)

src_configure() {
	local mycmakeargs=(
		-DENABLE_DOCS=$(usex doc)
		-DBUILD_SHARED_LIBS=ON
		-DLIBSUPERMESH_AUTO_COMPILER_FLAGS=OFF
		-DLIBSUPERMESH_DOUBLE_PRECISION=$(usex double)
		-DLIBSUPERMESH_ENABLE_JUDY=$(usex judy)
		-DLIBSUPERMESH_ENABLE_TIMERS=$(usex timers)
		-DLIBSUPERMESH_OVERLAP_COMPUTE_COMMS=$(usex overlap_comms)
	)
	cmake_src_configure
}
