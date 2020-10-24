# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PREFIX_TOOLS_CLUSTER="USC Discovery"
inherit prefix-tools

src_install() {
	prefix-tools_src_install
	doexe discovery/mpirun
}
