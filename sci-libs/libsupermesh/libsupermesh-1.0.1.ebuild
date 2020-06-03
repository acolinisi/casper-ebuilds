# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils fortran-2

DESCRIPTION="Parallel supermeshing library"
HOMEPAGE="https://bitbucket.org/libsupermesh/libsupermesh"
SRC_URI="https://bitbucket.org/libsupermesh/${PN}/downloads/${P}.tar.gz"

SLOT="0"
LICENSE="LGPL-2.1"
KEYWORDS="~amd64 ~amd64-linux"
IUSE="doc +judy timers overlap_comms +double test"

# TODO: uses private headers from libspatialindex....
#	sci-libs/libspatialindex
DEPEND=">=virtual/mpi-2
	doc? ( virtual/latex-base )
	judy? ( dev-libs/judy )
	"

PATCHES=(
	"${FILESDIR}/${P}-cmake-docs.patch"
	"${FILESDIR}/${P}-cmake-lib.patch"
	"${FILESDIR}/${P}-cmake-libspatialindex.patch"
	"${FILESDIR}/${P}-cmake-include.patch"
	"${FILESDIR}/${P}-cxx11.patch"
	)

#-DENABLE_DOCS=$(usex test)
src_configure() {
	local mycmakeargs=(
		-DENABLE_DOCS=OFF
		-DBUILD_SHARED_LIBS=ON
		-DUSE_VENDORED_LIBSPATIALINDEX=ON
		-DLIBSUPERMESH_AUTO_COMPILER_FLAGS=OFF
		-DLIBSUPERMESH_DOUBLE_PRECISION=$(usex double)
		-DLIBSUPERMESH_ENABLE_JUDY=$(usex judy)
		-DLIBSUPERMESH_ENABLE_TIMERS=$(usex timers)
		-DLIBSUPERMESH_OVERLAP_COMPUTE_COMMS=$(usex overlap_comms)
	)
	cmake-utils_src_configure
}
