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
IUSE="cm cuda debug gdrcopy java knem +numa +openmp rocm rdmacm ugni verbs xpmem"

RDEPEND="
	sys-libs/binutils-libs:=
	numa? ( sys-process/numactl )
"
DEPEND="${RDEPEND}"

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
		$(use_enable numa) \
		$(use_enable openmp) \
		$(use_with cm) \
		$(use_with cuda) \
		$(use_with gdrcopy) \
		$(use_with java) \
		$(use_with knem) \
		$(use_with rdmacm) \
		$(use_with rocm) \
		$(use_with ugni) \
		$(use_with verbs) \
		$(use_with xpmem)
}

src_compile() {
	BASE_CFLAGS="" emake
}
