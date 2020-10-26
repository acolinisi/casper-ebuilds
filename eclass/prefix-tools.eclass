# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: prefix-tools.eclass
# @MAINTAINER:
# Alexei Colin <acolin@isi.edu>
# @BLURB: Install executables for using Prefix on a specific HPC clusters

# @ECLASS-VARIABLE: PREFIX_TOOLS_CLUSTER
# @REQUIRED
# @DESCRIPTION: The name of the cluster that the tools are for (for display)

# @ECLASS-VARIABLE: PREFIX_TOOLS_CLUSTERS
# @INTERNAL
# @DESCRIPTION: List of supported clusters (suffixes of package names)
PREFIX_TOOLS_CLUSTERS=(usc-discovery anl-theta)

# @ECLASS-VARIABLE: PREFIX_TOOLS_HOST_DIR
# @INTERNAL
# @DESCRIPTION: Installation directory for host-side tools
PREFIX_TOOLS_HOST_DIR="/ptools"

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

DESCRIPTION="Tools for running Gentoo Prefix on ${PREFIX_TOOLS_CLUSTER} cluster"
HOMEPAGE="https://github.com/ISI-apex/casper-utils"
SLOT="0"
LICENSE="GPL-3"
IUSE=""

S="${WORKDIR}/${P}/prefix-tools/clusters"

EXPORT_FUNCTIONS src_install

prefix-tools_get_conflicts() {
	local conflicts=()
	local cluster
	for cluster in "${PREFIX_TOOLS_CLUSTERS[@]}"; do
		if [[ ! ${PN} =~ ${cluster}$ ]]; then
			conflicts+=("!app-portage/prefix-tools-${cluster}")
		fi
	done
	echo "${conflicts[@]}"
}

prefix-tools_src_install() {
	local exec_path="/usr/libexec/prefix-tools/bin"
	exeinto ${exec_path}

	cat >> "${T}"/01prefix-tools <<-EOF
	PATH="${EPREFIX}${exec_path}"
	EOF
	doenvd "${T}"/01prefix-tools
}

prefix-tools_config_host_install() {
	insinto ${PREFIX_TOOLS_HOST_DIR}
	exeinto ${PREFIX_TOOLS_HOST_DIR}
}

DEPEND="$(prefix-tools_get_conflicts)"
