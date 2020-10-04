# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# TODO: the upstream was renated to openpmix

EAPI=7

inherit git-r3

DESCRIPTION="Reference implementation of the Process Management Interface Exascale (PMIx)"
HOMEPAGE="https://openpmix.org/"
EGIT_REPO_URI="https://github.com/openpmix/openpmix.git"

# TODO: confirm that openmpi complains, and needs rebuild
SLOT="0/$(ver_cut 1-2)"
LICENSE="BSD"
KEYWORDS=""
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

src_prepare() {
	default
	./autogen.pl || die
}

src_configure() {
	econf \
		$(use_enable debug) \
		$(use_enable pmi pmi-backward-compatibility) \
		$(use_with munge munge ${EPREFIX}/usr) \
		$(use_with hwloc hwloc ${EPREFIX}/usr) \
		--with-libevent=${EPREFIX}/usr
}
