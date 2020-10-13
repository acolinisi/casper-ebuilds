# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

MY_PN="spatialindex-src"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="General framework for developing spatial indices"
HOMEPAGE="http://libspatialindex.github.com/"
SRC_URI="https://github.com/libspatialindex/${PN}/releases/download/${PV}/${MY_P}.tar.bz2"

SLOT="0/6"
LICENSE="MIT"
KEYWORDS="~amd64 ~amd64-linux ~x86"
IUSE="test"

S=${WORKDIR}/${MY_P}

src_configure() {
	local mycmakeargs=(
		-DSIDX_BUILD_TESTS=$(usex test)
	)
	cmake_src_configure
}
