# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

MY_PN=FreeFem

DESCRIPTION="High-level multiphysics FEM software for solving PDEs on 2D and 3D domains"
HOMEPAGE="http://www.freefem.org/"
SRC_URI="https://github.com/${MY_PN}/${MY_PN}-sources/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~amd64-linux"
IUSE="cblas doc examples fftw hdf5 lapack ipopt metis mumps mpi nlopt
	scalapack scotch superlu tetgen umfpack"

REQUIRED_USE=""

# See cmake/modules/ff_configure_thirdparty_optional.cmake for list
BDEPEND="virtual/pkgconfig"
DEPEND="
	dev-libs/flex
	sci-libs/amd
	sci-libs/arpack
	sci-libs/cholmod
	sci-libs/colamd
	fftw? ( sci-libs/fftw:3.0 )
	sci-libs/gsl
	sci-libs/hdf5
	ipopt? ( sci-libs/ipopt )
	lapack? ( sci-libs/lapack )
	metis? ( || ( sci-libs/metis sci-libs/parmetis ) )
	mumps? ( sci-libs/mumps )
	nlopt? ( sci-libs/nlopt )
	scotch? ( sci-libs/scotch )
	sci-libs/suitesparseconfig
	superlu? ( sci-libs/superlu )
	tetgen? ( sci-libs/tetgen )
	sci-libs/umfpack
	cblas? ( virtual/cblas )
	mpi? ( virtual/mpi )
	"

RDEPEND="${DEPEND}
	doc? (
		dev-texlive/texlive-latexrecommended
		dev-texlive/texlive-latexextra
		virtual/latex-base
		media-gfx/imagemagick
		)"

S="${WORKDIR}/${MY_PN}-sources-${PV}"

	#CBLAS
	#FFTW
	#IPOPT
	#LAPACK
	#METIS
	#MPI
	#MUMPS
	#NLOPT
	#SCOTCH
	#SUPERLU
	#TETGEN
	#UMFPACK

src_configure() {
	local mycmakeargs+=(
		-DCBLAS_LIBRARIES="$($(tc-getPKG_CONFIG) --libs cblas)"
		-DCBLAS_INCLUDES="$($(tc-getPKG_CONFIG) --cflags cblas)"
		-DIPOPT_INCLUDES="${EPREFIX}/usr/include/coin-or"
		-DWITH_CBLAS=$(usex cblas)
		-DWITH_FFTW=$(usex fftw)
		-DWITH_IPOPT=$(usex ipopt)
		-DWITH_LAPACK=$(usex lapack)
		-DWITH_METIS=$(usex metis)
		-DWITH_MPI=$(usex mpi)
		-DWITH_MUMPS=$(usex mumps)
		-DWITH_NLOPT=$(usex nlopt)
		-DWITH_SCOTCH=$(usex scotch)
		-DWITH_SUPERLU=$(usex superlu)
		-DWITH_TETGEN=$(usex tetgen)
		-WITH_UMFPACK=ON
		-LAH
	)
		#-DCMAKE_SHARED_LINKER_FLAGS="$($(tc-getPKG_CONFIG) --libs arpack)"
	cmake_src_configure
}

#src_test() {
#	if use mpi; then
#		# This may depend on the used MPI implementation. It is needed
#		# with mpich2, but should not be needed with lam-mpi or mpich
#		# (if the system is configured correctly).
#		ewarn "Please check that your MPI root ring is on before running"
#		ewarn "the test phase. Failing to start it before that phase may"
#		ewarn "result in a failing emerge."
#		epause
#	fi
#	emake -j1 check
#}

src_install() {
	default

	insinto /usr/share/doc/${PF}
	if use doc; then
		doins DOC/freefem++doc.pdf
	fi

	if use examples; then
		einfo "Installing examples..."

		# Remove compiled examples:
		emake clean

		einfo "Some of the installed examples assumes that the user has write"
		einfo "permissions in the working directory and other will look for"
		einfo "data files in the working directory. For this reason in order to"
		einfo "run the examples it's better to temporary copy them somewhere"
		einfo "in the user folder. For example to run the tutorial examples"
		einfo "it's better to copy the entire examples++-tutorial folder into"
		einfo "the user directory."

		rm -f examples*/Makefile* || die
		doins -r examples*
	fi
}

