# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

inherit autotools

DESCRIPTION="MPI library for algorithmic differentiation"
HOMEPAGE="http://www.mcs.anl.gov/~utke/AdjoinableMPI/AdjoinableMPIDox/index.html"

# hg clone http://mercurial.mcs.anl.gov/ad/AdjoinableMPI
# cd AdjoinableMPI
# hg archive ../ampi-0_pre$(hg log -l1 --template '{date(date, "%Y%m%d")}').tar.gz
SRC_URI="https://dev.gentoo.org/~jauhien/distfiles/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86"

RDEPEND="virtual/mpi"
DEPEND="${RDEPEND}"

src_prepare() {
	eautoreconf
}
