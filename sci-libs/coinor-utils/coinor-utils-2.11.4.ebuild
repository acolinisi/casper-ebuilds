# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools multilib toolchain-funcs

MYPN=CoinUtils
MYSRCDIR=${MYPN}-releases-${PV}

# Buildtools needed only for eautoreconf, which is needed as a workaround
BUILDTOOLS_PV=0.8.10
BUILDTOOLS_P=coin-buildtools-${BUILDTOOLS_PV}
BUILDTOOLS_SRCDIR=BuildTools-releases-${BUILDTOOLS_PV}

DESCRIPTION="COIN-OR Matrix, Vector and other utility classes"
HOMEPAGE="
	https://github.com/coin-or/CoinUtils
	https://projects.coin-or.org/CoinUtils
	"
SRC_URI="https://github.com/coin-or/${MYPN}/archive/releases/${PV}.tar.gz -> ${P}.tar.gz
	 https://github.com/coin-or-tools/BuildTools/archive/releases/${BUILDTOOLS_PV}.tar.gz -> ${BUILDTOOLS_P}.tar.gz
	"

LICENSE="EPL-1.0"
SLOT="0/3"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
# TODO: aboca
IUSE="bzip2 doc glpk blas lapack static-libs test zlib"

# Coin6001E Unable to open mps input file ../../Data/Sample/exmip1.mps
# That file doesn't appear to be in the tarball (?)
RESTRICT="!test? ( test )"

BDEPEND="
	virtual/pkgconfig
	doc? ( app-doc/doxygen[dot] )
	test? ( sci-libs/coinor-sample )
	"
RDEPEND="
	sys-libs/readline:0=
	bzip2? ( app-arch/bzip2 )
	blas? ( virtual/blas )
	glpk? ( sci-mathematics/glpk:= )
	lapack? ( virtual/lapack )
	zlib? ( sys-libs/zlib )"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${MYSRCDIR}/${MYPN}"

src_prepare() {
	dodir /usr
	#sed \
	#	-e "s:lib/pkgconfig:$(get_libdir)/pkgconfig:g" \
	#	-i configure || die

	# Needed to fix HAVE_CFLOAT undefined in config_coinutils.h (look slike
	# this is due to upstream not autoreconf'ing before release); but to
	# autoreconf, we need to install build tools.

	pushd "${WORKDIR}" >/dev/null
	unpack ${BUILDTOOLS_P}.tar.gz
	popd >/dev/null

	install -D -t . ${WORKDIR}/${BUILDTOOLS_SRCDIR}/coin.m4
	install -D -t BuildTools ${WORKDIR}/${BUILDTOOLS_SRCDIR}/Makemain.inc

	# Needed for the eautoheader commands below to actually produce the missing HAVE_CFLOAT
	AT_M4DIR=. eaclocal

	# acheader only gens 1st one, but the 2nd one is the one broken; regen it manually
	# (autotools recommends using only one with includes, but until upstream changes...)
	sed -i -e 's#^\s*\(AC_CONFIG_HEADER\)(\[\s*\(src/config.h\)\s\+\(src/config_coinutils.h\)\s*\])#\1([\3 \2])#' \
		configure.ac
	AT_M4DIR=. eautoheader -f

	AT_M4DIR=. eautoreconf
	default
}

src_configure() {
	local myeconfargs=(
		--enable-dependency-linking
		--with-coin-instdir="${ED}"/usr
		$(use_enable zlib)
		$(use_enable bzip2 bzlib)
		$(use_with doc dot)
	)
	if use blas; then
		myeconfargs+=( --with-blas-lib="$($(tc-getPKG_CONFIG) --libs blas)" )
	else
		myeconfargs+=( --without-blas )
	fi
	if use glpk; then
		myeconfargs+=(
			--with-glpk-incdir="${EPREFIX}"/usr/include
			--with-glpk-lib=-lglpk
		)
	else
		myeconfargs+=( --without-glpk )
	fi
	if use lapack; then
		myeconfargs+=( --with-lapack="$($(tc-getPKG_CONFIG) --libs lapack)" )
	else
		myeconfargs+=( --without-lapack )
	fi

	econf "${myeconfargs[@]}"
}

src_compile() {
	emake CFLAGS="${CFLAGS}"  CXXFLAGS="${CXXFLAGS}"  CPPFLAGS="${CPPFLAGS}" all $(usex doc doxydoc "")
}

src_test() {
	emake test
}

src_install() {
	use doc && HTML_DOC=("${BUILD_DIR}/doxydocs/html/")
	default
	# already installed
	rm "${ED}"/usr/share/coin/doc/${MYPN}/{README,AUTHORS,LICENSE} || die
}
