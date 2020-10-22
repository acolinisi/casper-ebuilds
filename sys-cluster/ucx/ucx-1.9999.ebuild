# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit git-r3

DESCRIPTION="Unified Communication X"
HOMEPAGE="http://www.openucx.org"
EGIT_REPO_URI="https://github.com/openucx/ucx.git"

if [[ "$(ver_cut 4 ${PV})" = "p" ]]
then
	MY_D="$(ver_cut 5 ${PV})"
	EGIT_COMMIT_DATE="${MY_D:0:4}-${MY_D:4:2}-${MY_D:6:2}"
	KEYWORDS="~amd64 ~amd64-linux"
else # live
	KEYWORDS=""
fi

# subslotted because openmpi needs to be rebuilt when UCX minor changes
SLOT="0/$(ver_cut 1-2)"
LICENSE="BSD"
IUSE_UCX_IB="
	ucx_ib_cm
	ucx_ib_rc
	ucx_ib_ud
	ucx_ib_dc
	ucx_ib_mlx5-dv
	ucx_ib_hw-tm
	ucx_ib_dm
"
IUSE="cuda debug doc gdrcopy java knem +mt +numa ofed +openmp rocm rdmacm ugni xpmem ${IUSE_UCX_IB}"

RDEPEND="
	sys-libs/binutils-libs:=
	numa? ( sys-process/numactl )
	ofed? ( sys-fabric/ofed:* )
"
DEPEND="${RDEPEND}
	doc? ( app-doc/doxygen )"

src_prepare() {
	default
	./autogen.sh || die
}

src_configure() {
	if use ugni && [[ -n "${EPREFIX}" ]]; then
		# For configure to find the Cray libs
		local prefix_pc_path="${EPREFIX}/usr/$(get_libdir)/pkgconfig"
		local host_pc_path="/usr/$(get_libdir)/pkgconfig"
	fi

	# TODO: system cflags not propagated to build commands
	BASE_CFLAGS=""
	PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:${prefix_pc_path}:${host_pc_path}" \
	econf \
		--disable-compiler-opt \
		$(use_enable debug) \
		$(use_enable debug logging) \
		$(use_enable debug assertions) \
		$(use_enable doc doxygen-doc) \
		$(use_enable mt) \
		$(use_enable numa) \
		$(use_enable openmp) \
		$(use_with ucx_ib_cm cm) \
		$(use_with ucx_ib_rc rc) \
		$(use_with ucx_ib_ud ud) \
		$(use_with ucx_ib_dc dc) \
		$(use_with ucx_ib_mlx5-dv mlx5-dv) \
		$(use_with ucx_ib_hw-tm ib-hw-tm) \
		$(use_with ucx_ib_dm dm) \
		$(use_with cuda) \
		$(use_with gdrcopy) \
		$(use_with java) \
		$(use_with knem) \
		$(use_with rdmacm) \
		$(use_with rocm) \
		$(use_with ugni) \
		$(use_with ofed verbs) \
		$(use_with xpmem)
}

src_compile() {
	BASE_CFLAGS="" emake
}
