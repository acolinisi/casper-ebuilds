# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

EGIT_REPO_URI="https://github.com/ISI-apex/casper-utils.git"
EGIT_SUBMODULES=()

if [[ "$(ver_cut 2 ${PV})" = "pre" ]]
then
	MY_D="$(ver_cut 3 ${PV})"
	EGIT_COMMIT_DATE="${MY_D:0:4}-${MY_D:4:2}-${MY_D:6:2}"
	KEYWORDS="~amd64 ~amd64-linux"
else # live
	KEYWORDS=""
fi

inherit git-r3

DESCRIPTION="Tools for running commands within Gentoo Prefix"
HOMEPAGE="https://github.com/ISI-apex/casper-utils"
SLOT="0"
LICENSE="GPL-3"
IUSE=""

S="${WORKDIR}/${P}/prefix-tools"

src_install() {
	insinto /etc/${PN}

	sed -e "s:@__EPREFIX__@:${EPREFIX}:g" \
		-e "s:@__ETC_PTOOLS__@:etc/${PN}:g" \
		etc/prefixrc > "${T}"/prefixrc
	doins "${T}"/prefixrc

	doins etc/prefixenv
	doins etc/prefixhelpers

	for f in bin/*; do
		dobin $f
	done

	local ptools_dir=/ptools
	insinto ${ptools_dir}
	exeinto ${ptools_dir}
	doins host/pscommon.sh
	for f in host/*; do
		doexe $f
	done
}
