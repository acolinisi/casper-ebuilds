# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Virtual for Process Management Interface (PMI) v2 implementation"
SLOT="0"
KEYWORDS="~amd64 ~amd64-linux"
IUSE=""

RDEPEND="|| (
	sys-cluster/libpmi2-slurm
	sys-cluster/slurm[pmi2]
	sys-cluster/pmix[pmi] 
)"
