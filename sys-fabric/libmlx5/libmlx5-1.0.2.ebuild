# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="OpenIB userspace driver for Mellanox ConnectX HCA"
HOMEPAGE="https://www.openfabrics.org/downloads/mlx5/"
SRC_URI="https://www.openfabrics.org/downloads/mlx5/${P}.tar.gz"
KEYWORDS="amd64 ~x86 ~amd64-linux"
LICENSE="BSD GPL-2"
IUSE=""
SLOT="0"

DEPEND="sys-fabric/libibverbs:${SLOT}"
RDEPEND="!sys-fabric/openib-userspace"

PATCHES=("${FILESDIR}"/${PN}-1.0.1-strncpy.patch)
