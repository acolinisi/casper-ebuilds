# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Pkg-config files for Cray libraries (ALPS, PMI, ...) in host system"
HOMEPAGE=""
SRC_URI=""
KEYWORDS="~amd64 ~amd64-linux"

LICENSE="BSD" # dummy
SLOT="0"
IUSE=""

src_unpack() {
	mkdir -p "${S}"
	:
}
src_configure() {
	:
}
src_compile() {
	:
}

src_install() {
	local libs=(cray-ugni cray-gni-headers cray-xpmem
		cray-alps cray-alpsutil cray-alpslli
		cray-udreg cray-wlm_detect
		cray-pmi cray-rca cray-krca cray-sysutils lsb-cray-hss)
	for lib in ${libs[@]}
	do
		dosym /usr/lib64/pkgconfig/${lib}.pc \
			/usr/$(get_libdir)/pkgconfig/${lib}.pc
	done

	dobin "${FILESDIR}"/crayrun
	local expr="s:@__LIBS__@:${libs[@]}:g"
	sed -i -e "${expr}" -e "s:@__PREFIX__@:${EPREFIX}:g" \
		${ED}/usr/bin/crayrun
}
