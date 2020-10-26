# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PREFIX_TOOLS_CLUSTER="USC Discovery"
MY_CLUSTER="usc-discovery"
inherit prefix-tools

src_install() {
	prefix-tools_src_install
	doexe ${MY_CLUSTER}/mpirun

	prefix-tools_config_host_install
	for b in ${MY_CLUSTER}/host/*; do
		doexe ${b}
	done
	doins ${MY_CLUSTER}/host/pscommon.sh
}
