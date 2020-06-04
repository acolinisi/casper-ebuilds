# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5

DESCRIPTION="Meta package for a suite of sparse matrix tools"
HOMEPAGE="http://www.suitesparse.com \
	  http://faculty.cse.tamu.edu/davis/suitesparse.html"

LICENSE="LGPL-2.1 GPL-2"
SLOT="0"

KEYWORDS="~amd64 ~amd64-linux"
IUSE="cuda partition tbb"
DEPEND=""
RDEPEND="
	>=sci-libs/suitesparseconfig-${PV}
	>=sci-libs/amd-2.4.6-r1
	>=sci-libs/btf-1.2.6
	>=sci-libs/camd-2.4.6-r1
	>=sci-libs/ccolamd-2.9.6-r1
	>=sci-libs/cholmod-3.0.14-r1[cuda?,partition?]
	>=sci-libs/colamd-2.9.6-r1
	>=sci-libs/cxsparse-3.2.0
	>=sci-libs/klu-1.3.9-r1
	>=sci-libs/ldl-2.2.6-r1
	>=sci-libs/spqr-2.0.9[partition?,tbb?]
	>=sci-libs/umfpack-5.7.9[cholmod]"
