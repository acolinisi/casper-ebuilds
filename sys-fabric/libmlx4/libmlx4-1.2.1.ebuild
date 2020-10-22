# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="OpenIB userspace driver for Mellanox ConnectX HCA"
HOMEPAGE="https://www.openfabrics.org/downloads/mlx4/"
SRC_URI="https://www.openfabrics.org/downloads/mlx4/${P}.tar.gz"
# disabled because requires libibvers > 1.2 (OFED >> 3.17,
# but after OFED 4.8 userspace drivers were moved to rdma-core)
KEYWORDS=""
LICENSE="BSD GPL-2"
IUSE=""
SLOT="0"

DEPEND="sys-fabric/libibverbs:${SLOT}"
RDEPEND="!sys-fabric/openib-userspace"
