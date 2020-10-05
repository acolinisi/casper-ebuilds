# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="The Process Management Interface (PMI) Exascale"
HOMEPAGE="https://pmix.github.io/pmix/"
MY_PV=$(ver_rs 3 "")
SRC_URI="https://github.com/pmix/pmix/releases/download/v${MY_PV}/${PN}-${MY_PV}.tar.bz2"

# TODO: confirm that openmpi complains, and needs rebuild
SLOT="0/$(ver_cut 1-2)"
LICENSE="BSD"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE="debug +munge pmi +hwloc"

# TODO: if add a pmi use flag to sys-cluster/slurm, then update
# the conflict here to sys-cluster/slurm[!pmi]
# TODO: possible to declare conflict on the whole virtual/pmi-{1,2}?
# TODO: is this used at all? sys-cluster/ucx
RDEPEND="
	dev-libs/libevent:0=
	sys-libs/zlib:0=
	hwloc? ( sys-apps/hwloc )
	munge? ( sys-auth/munge )
	pmi? ( !sys-cluster/slurm )
	"
DEPEND="${RDEPEND}"

src_configure() {
	econf \
		$(use_enable debug) \
		$(use_enable pmi pmi-backward-compatibility) \
		$(use_with munge munge ${EPREFIX}/usr) \
		$(use_with hwloc hwloc ${EPREFIX}/usr) \
		--with-libevent=${EPREFIX}/usr
}
