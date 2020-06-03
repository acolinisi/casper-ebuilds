# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

MY_PN="spatialindex-src"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="General framework for developing spatial indices"
HOMEPAGE="http://libspatialindex.github.com/"
SRC_URI="http://download.osgeo.org/libspatialindex/${MY_P}.tar.bz2"
LICENSE="MIT"

KEYWORDS="amd64 x86"
SLOT="0/4"
IUSE="debug static-libs"

S=${WORKDIR}/${MY_P}

PATCHES=(
	"${FILESDIR}"/${PN}-1.8.1-QA.patch
)

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf $(use_enable debug)
}
