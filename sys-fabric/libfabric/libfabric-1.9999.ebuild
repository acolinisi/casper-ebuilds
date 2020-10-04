# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools toolchain-funcs git-r3

DESCRIPTION="OpenFabrics Interfaces (OFI) framework for exporting fabric communication services to applications"
HOMEPAGE="http://libfabric.org"
EGIT_REPO_URI="https://github.com/ofiwg/libfabric.git"
LICENSE="BSD"
SLOT="0"
KEYWORDS=""
# TODO: netdir
IUSE="bgq debug efa gni mrail perf
	psm psm2 rstream rxd rxm shm sockets tcp udp
	usnic verbs"

DEPEND="
	gni? ( >=sys-devel/gcc-4.9 )
	verbs? ( sys-fabric/ofed:* )"

PATCHES=("${FILESDIR}"/${PN}-1.11.0-make-extra-ldflags.patch)

src_prepare() {
	default
	./autogen.sh || die
	eautomake
}

src_configure() {
	# uGNI is a proprietary lib provided by the host OS outside of
	# Prefix (configure doesn't let us override pkgconfig path per lib)
	if use gni && [[ -n "${EPREFIX}" ]]; then
		# For configure to find the libs
		local prefix_pc_path="${EPREFIX}/usr/$(get_libdir)/pkgconfig"
		local host_pc_path="/usr/$(get_libdir)/pkgconfig"

		# Workaround for bug(?) in configure: it finds the GNI
		# headers via pkg-config, but then does not use that
		# information later, instead uses a var (echo is to strip
		# a trailing space)
		$(tc-getPKG_CONFIG) --with-path="${host_pc_path}" \
			--exists cray-gni-headers || die
		local gni_hdr_path="$(echo $($(tc-getPKG_CONFIG) \
			--with-path="${host_pc_path}" \
			--cflags cray-gni-headers))"
	fi
	PKG_CONFIG_PATH="${PKG_CONFIG_PATH}:${prefix_pc_path}:${host_pc_path}" \
	CRAY_GNI_HEADERS_INCLUDE_OPTS="${gni_hdr_path}" \
		econf \
		$(use_enable debug) \
		$(use_enable debug hook_debug) \
		$(use_enable bgq) \
		$(use_enable efa) \
		$(use_enable gni) \
		$(use_enable mrail) \
		$(use_enable perf) \
		$(use_enable psm) \
		$(use_enable psm2) \
		$(use_enable rstream) \
		$(use_enable rxd) \
		$(use_enable rxm) \
		$(use_enable shm) \
		$(use_enable sockets) \
		$(use_enable tcp) \
		$(use_enable udp) \
		$(use_enable usnic) \
		$(use_enable verbs)
}

src_compile() {
	# Workaround for linking failure, despite configure suceeding
	# NOTE: setting LIBS during configure does not help
	if use gni && [[ -n "${EPREFIX}" ]]; then
		local host_pc_path="/usr/$(get_libdir)/pkgconfig"
		local gni_libs=(cray-ugni cray-xpmem cray-alpsutil cray-alpslli
				cray-udreg cray-wlm_detect)
		$(tc-getPKG_CONFIG) --with-path="${host_pc_path}" \
			--exists ${gni_libs[@]} || die
		local gni_ldflags="$($(tc-getPKG_CONFIG) \
			--with-path="${host_pc_path}" \
			--libs ${gni_libs[@]})"
	fi

	emake EXTRA_LDFLAGS="${gni_ldflags}"
}
