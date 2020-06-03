# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_8 )

inherit autotools python-single-r1

MYPN=ADOL-C

DESCRIPTION="Automatic differentiation system for C/C++"
HOMEPAGE="
	https://github.com/coin-or/ADOL-C
	https://projects.coin-or.org/ADOL-C/
"
SRC_URI="https://github.com/coin-or/${MYPN}/archive/releases/${PV}.tar.gz"

LICENSE="|| ( EPL-1.0 GPL-2 )"
SLOT="0/2"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~ppc ~ppc64 ~x86 ~amd64-linux ~x86-linux"
IUSE="+boost mpi sparse static-libs swig"

# Disallowing swig use flag becsause broken:
#   adolc-python_wrap.cpp:4947:26: error: cannot convert adub to int in return
REQUIRED_USE="
	swig? ( sparse )
	!swig
"

RDEPEND="
	boost? ( dev-libs/boost:0= )
	mpi? ( sys-cluster/ampi:0= )
	sparse? ( sci-libs/colpack:0= )"
DEPEND="${RDEPEND}"
BDEPEND="swig? ( ${PYTHON_DEPS}
		 dev-lang/swig
		 dev-python/numpy[${PYTHON_SINGLE_USEDEP}]
		)"

S="${WORKDIR}/${MYPN}-releases-${PV}"

PATCHES=(
	"${FILESDIR}"/${P}-no-colpack.patch
	"${FILESDIR}"/${PN}-2.5.0-pkgconfig-no-ldflags.patch
	"${FILESDIR}"/${PN}-2.6.2-dash.patch
	"${FILESDIR}"/${P}-typo-in-configure.patch
	"${FILESDIR}"/${P}-optional-swig.patch
	"${FILESDIR}"/${P}-swig-paths.patch
	"${FILESDIR}"/${P}-boost_system-error-msg.patch
)

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf \
		--enable-advanced-branching \
		--enable-atrig-erf \
		$(use_enable mpi ampi) \
		$(use_enable sparse) \
		$(use_enable static-libs static) \
		$(use_enable swig) \
		$(use_with boost boost ${EPREFIX}/usr) \
		$(use_with sparse colpack "${EPREFIX}"/usr)
}

src_test() {
	emake test
}

src_install() {
	default
	use static-libs || find "${ED}" -name '*.la' -delete
}
