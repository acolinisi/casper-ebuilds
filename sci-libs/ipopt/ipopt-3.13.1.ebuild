# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

FORTRAN_NEEDED="mumps"

inherit autotools fortran-2 toolchain-funcs

MY_PN=${PN^}
MY_P=${MY_PN}-${PV}

DESCRIPTION="Interior-Point Optimizer for large-scale nonlinear optimization"
HOMEPAGE="
	https://github.com/coin-or/Ipopt
	https://projects.coin-or.org/Ipopt/
	"
SRC_URI="https://github.com/coin-or/${MY_PN}/archive/releases/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="EPL-1.0 hsl? ( HSL )"
SLOT="0/1"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
IUSE="asl doc examples hsl java lapack mpi mumps static-libs test"
RESTRICT="test" # Fails to compile

BDEPEND="
	virtual/pkgconfig
	doc? ( app-doc/doxygen[dot] )
	test? ( sci-libs/coinor-sample sci-libs/mumps )
	java? ( virtual/jdk )
	"
RDEPEND="
	virtual/blas
	asl? ( sci-libs/asl )
	hsl? ( sci-libs/coinhsl:0= )
	java? ( virtual/jdk )
	lapack? ( virtual/lapack )
	mpi? ( virtual/mpi )
	mumps? ( sci-libs/mumps:0=[mpi=] )"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${MY_PN}-releases-${PV}"

src_prepare() {
	if use mpi ; then
		export CXX=mpicxx FC=mpif77 F77=mpif77 CC=mpicc
	fi
	default
}

src_configure() {
	# needed for --with-coin-instdir
	dodir /usr
		#--with-blas-lib="$($(tc-getPKG_CONFIG) --libs blas)"
		#--enable-dependency-linking
		#--with-coin-instdir="${ED%/}"/usr
	local myeconfargs=(
		$(use_with doc dot)
		$(use_enable java)
		$(use_with asl)
		$(use_with hsl)
		$(use_with lapack)
		$(use_with mumps)
	)

	#if use lapack; then
	#	myeconfargs+=( --with-lapack-lflags="$($(tc-getPKG_CONFIG) --libs lapack)" )
	#fi
	#if use mumps; then
	#	myeconfargs+=(
	#		--with-mumps-cflags="-I${EPREFIX}"/usr/include$(usex mpi '' '/mpiseq')
	#		--with-mumps-lflags="$($(tc-getPKG_CONFIG) --libs mumps)"
	#		)
	#		#--with-mumps-lib="-lmumps_common -ldmumps -lzmumps -lsmumps -lcmumps" )
	#fi
	#if use hsl; then
	#	myeconfargs+=(
	#		--with-hsl-cflags="${EPREFIX}"/usr/include
	#		--with-hsl-lflags="$($(tc-getPKG_CONFIG) --libs coinhsl)" )
	#fi
	econf "${myeconfargs[@]}"
}

src_compile() {
	emake all
	use doc && emake doxydoc
}

src_test() {
	emake test
}

src_install() {
	default
	local HTML_DOCS DOCS
	use doc && HTML_DOCS=("${S}/doxydoc/html/.")
	use examples && DOCS+=( examples )
	einstalldocs
}
