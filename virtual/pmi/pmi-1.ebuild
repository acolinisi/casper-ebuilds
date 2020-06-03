# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Virtual for Process Management Interface (PMI) v2 implementation"
SLOT="0"
KEYWORDS="~amd64 ~amd64-linux"
IUSE=""


# TODO: should there be >=sys-cluster/libpmi-slurm ? (problem is that slurm
# installs libpmi v1 by default)
# TODO: should there be a use-flag for pmi (v1) in slurm?
RDEPEND="|| (
	sys-cluster/pmix[pmi] 
	sys-cluster/slurm
)"
