# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

SLURM_PN=slurm

if [[ ${PV} == *9999* ]]; then
	EGIT_REPO_URI="https://github.com/SchedMD/slurm.git"
	INHERIT_GIT="git-r3"
	SRC_URI=""
	KEYWORDS=""
	MY_P="${P}"
else
	if [[ ${PV} == *pre* || ${PV} == *rc* ]]; then
		MY_PV=$(ver_rs '-0.') # pre-releases or release-candidate
	else
		MY_PV=$(ver_rs 1-3 '-') # stable releases
	fi
	MY_P="${SLURM_PN}-${MY_PV}"
	INHERIT_GIT=""
	SRC_URI="https://github.com/SchedMD/${SLURM_PN}/archive/${MY_P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

inherit autotools bash-completion-r1 pam perl-module prefix toolchain-funcs systemd ${INHERIT_GIT}

DESCRIPTION="Process Management Interface v2 (PMI2) implementation for the SLURM resource manager"
HOMEPAGE="https://www.schedmd.com https://github.com/SchedMD/slurm"

LICENSE="GPL-2"
SLOT="0"
IUSE="debug static-libs"

COMMON_DEPEND="dev-libs/libcgroup"

S="${WORKDIR}/${SLURM_PN}-${MY_P}"

RESTRICT="test"

src_unpack() {
	if [[ ${PV} == *9999* ]]; then
		git-r3_src_unpack
	else
		default
	fi
}

src_prepare() {
	#tc-ld-disable-gold
	eapply "${FILESDIR}"/disable-sview.patch
	default

	#hprefixify auxdir/{ax_check_zlib,x_ac_{lz4,ofed,munge}}.m4
	eautoreconf
}

src_configure() {
	# top-level configure configures contrib/pmi2 
	econf "${myconf[@]}" \
		--without-rpath \
		$(use_enable debug)
}

src_compile() {
	emake -C contribs/pmi2
}

src_install() {
	emake DESTDIR="${D}" -C contribs/pmi2 install

	mv "${ED}"/usr/include/slurm/* "${ED}"/usr/include/
	rmdir "${ED}"/usr/include/slurm

	use static-libs || find "${ED}" \( -name '*.a' -o -name '*.la' \) -exec rm {} +
}
