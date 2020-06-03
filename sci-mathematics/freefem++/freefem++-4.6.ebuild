# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

#inherit autotools eutils flag-o-matic mpi versionator toolchain-funcs
inherit autotools flag-o-matic fortran-2 toolchain-funcs

MY_PN=FreeFem

DESCRIPTION="High-level multiphysics FEM software for solving PDEs on 2D and 3D domains"
HOMEPAGE="http://www.freefem.org/"
SRC_URI="https://github.com/${MY_PN}/${MY_PN}-sources/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~amd64-linux"
IUSE="bemtool doc debug examples complex-scalars hdf5 hpddm htool index-64bit
	+lapack gmm ipopt metis mmg mumps parmetis parmmg mpi nlopt opengl petsc
	scalapack scotch superlu tetgen umfpack"

REQUIRED_USE="
	?? ( metis parmetis )
	parmmg? ( mpi )
	"

# TODO: cadna_c, mshmet, yams, pipe, MMAP, NewSolver, bem
# TODO: mkl
# TODO: virtual/mpi
BDEPEND="virtual/pkgconfig"
DEPEND="
	virtual/cblas
	sci-libs/arpack
	sci-libs/fftw:3.0
	sci-libs/gsl
	hdf5? ( <sci-libs/hdf5-1.12 )
	lapack? ( virtual/lapack )
	mpi? ( sys-cluster/openmpi )
	umfpack? ( sci-libs/umfpack[cholmod] )
	gmm? ( sci-mathematics/gmm )
	hpddm? ( sci-libs/hpddm )
	htool? ( sci-libs/htool )
	ipopt? ( sci-libs/ipopt )
	metis? ( sci-libs/metis )
	mumps? ( sci-libs/mumps[index-64bit=] )
	nlopt? ( sci-libs/nlopt )
	opengl? (
		media-libs/freeglut
		virtual/opengl
		)
	parmetis? ( sci-libs/parmetis )
	petsc? (
		sci-mathematics/petsc[complex-scalars=,index-64bit=]
		sci-mathematics/slepc[complex-scalars=,index-64bit=]
		)
	scalapack? ( sci-libs/scalapack )
	scotch? ( sci-libs/scotch )
	superlu? ( sci-libs/superlu )
	tetgen? ( sci-libs/tetgen )
	"

RDEPEND="${DEPEND}
	doc? (
		dev-texlive/texlive-latexrecommended
		dev-texlive/texlive-latexextra
		virtual/latex-base
		media-gfx/imagemagick
		)"

S="${WORKDIR}/${MY_PN}-sources-${PV}"

#	acoptim : acoptim.m4 forced -O2 removal
#	no-doc-autobuild: do not try to do a forced "manual" install of ex+doc
#	path: Honor FHS
#"${FILESDIR}"/${P}-configure-lib-ok.patch
PATCHES=(
	"${FILESDIR}"/${P}-acoptim.patch
	"${FILESDIR}"/${P}-prefix-path.patch
	"${FILESDIR}"/${P}-make-rm-mv.patch
	"${FILESDIR}"/${P}-configure-opengl.patch
	"${FILESDIR}"/${P}-configure-opengl-func.patch
	"${FILESDIR}"/${P}-configure-mpi.patch
	"${FILESDIR}"/${P}-configure-bemtool.patch
	"${FILESDIR}"/${P}-configure-freeyams.patch
	"${FILESDIR}"/${P}-configure-htool.patch
	"${FILESDIR}"/${P}-configure-tool-order.patch
	"${FILESDIR}"/${P}-configure-gl-message.patch
	"${FILESDIR}"/${P}-configure-lib-check3.patch
	"${FILESDIR}"/${P}-configure-lib-check3.1.patch
	)
	#"${FILESDIR}"/${P}-configure-add-message.patch
	#"${FILESDIR}"/${P}-configure-tool-ok.patch

	# needed when hdf5 is disabled?
	#"${FILESDIR}"/${P}-configure-hdf5.patch

	#"${FILESDIR}"/${PN}-no-doc-autobuild.patch
	#"${FILESDIR}"/${PN}-path.patch

src_prepare() {
	default
	eautoreconf
}

# usage: ff_use_pc use_flag library incdir lib
# NOTE: result via appending to list, because echo for $() breaks with spaces
ff_use() {
	local flag=$1
	local lib=$2
	local incdir=$3
	local libs=$4
	# not local
	my_ff_conf+=(
		$(use_enable ${flag} ${lib})
	)
	if use ${flag}; then
		# TODO: is --with-$2 also needed? or is it synonym of --with-$2-include
		my_ff_conf+=(
			--with-${lib}-include="${incdir}"
			--with-${lib}-ldflags="${libs}"
			)
	fi
}
# usage: ff_use_pc use_flag [library [option]]
ff_use_pc() {
	local flag=$1
	local lib=${2:-${flag}}
	local opt=${3:-${lib}}
	# not local
	my_ff_conf+=(
		$(use_enable ${flag} ${opt})
	)
	if use ${flag}; then
		## TODO: is --with-$2 also needed? or is it synonym of --with-$2-include
		my_ff_conf+=(
			--with-${opt}-include="$($(tc-getPKG_CONFIG) --cflags ${lib} | \
				sed 's/-I//g')"
			--with-${opt}-ldflags="$($(tc-getPKG_CONFIG) --libs ${lib})"
			)
	fi
}

src_configure() {

	local mpi_cxx_libs
	if use mpi; then
		# ugly, but the problem is that freefem is not smart enough to know to
		# always use the mpi compiler wrapper when linking against parmmg
		#if has_version sys-cluster/openmpi; then
			mpi_cxx_libs="$($(tc-getPKG_CONFIG) --libs ompi-cxx)"
		#else
			#die "no supported mpi implementation found"
		#fi
	fi

	# TODO: is tetgen and hpddm used in FreeFEM directly or only for PETSc?
	#   bad tetgen causes link errors, so it is used

	# TODO: apply HDF5 configure patch

	# Note: if we trust the summary output, libraries are still being probed
	# and selected despite --disable-LIB.

	# ff_use_pc for optional with .pc, for non-optional call pkg-config here
	# Notable deviations from the pattern:
	#   hdf5: configured via h5cc binary
	#   gmm: header-only library, no .pc
	#   glut: does not have --with-glut-ldflags
	#   mumps_seq: sci-libs/mumps is not the sequential version
	#   petsc: no --{en,dis}able-petsc, only --without-petsc{,_complex}
	#   slepc: no --enable-slepc, no --without-slepc
	#   --disable-openblas: disable automatic download of OpenBLAS
	#   ^ assuming this pertains to download only and not to use of the lib
	#   --enable-gsltest: do try to compile a GSL test program
	#   ^ assuming GSL is required, and this only chooses whether to probe
	#   --enable-system_*: set this for the few libs that have this flag
	#   --disable-*: no ebuild; and many require patches, private headers
	#      mshmet, yams: heavily patched by FreeFEM++ (could fetch and unpack)
	#      cadna: doesn't work with any upstream version, nor any link to fork
	#      mkl (Intel Math Kernel Library): not tested
	#   plugins (not deps): pipe, MMAP, NewSolver
	#	--disable-ffcs: do not build for the FreeFem++-cs IDE
	#  --enable-fortran and F77 is required because fortran sources are not
	#  		excluded form build and ff-c++ script breaks otherwise

	local petsc_args
	if use petsc; then
		local libdir="${EPREFIX}/usr/$(get_libdir)"
		local pc_path_args=(
			--with-path="${libdir}/slepc/lib/pkgconfig"
			--with-path="${libdir}/petsc/lib/pkgconfig"
			)
		# no --without-slepc{,complex} flags
		petsc_args=(
			--with-petsc$(usex complex-scalars _complex "")="${libdir}/petsc/lib/petsc/conf/petscvariables"
			--without-petsc$(usex complex-scalars "" _complex)
			--with-slepc$(usex complex-scalars complex "")-include="$($(tc-getPKG_CONFIG) \
				${pc_path_args[@]} --cflags SLEPc)"
			--with-slepc$(usex complex-scalars complex "")-ldflags="$($(tc-getPKG_CONFIG) \
				${pc_path_args[@]} --libs SLEPc)"
		)
	else
		petsc_args=(
			--without-petsc
			--without-petsc_complex
			)
	fi
	
	local my_ff_conf=(
		--disable-download
		--disable-openblas
		--enable-summary
		--disable-ffcs
		--enable-fortran
		--disable-c
		--disable-optim
		--disable-profiling
		--enable-generic
		--disable-static
		$(use_enable debug)
		--without-cadna
		--disable-mshmet
		--disable-freeyams
		--disable-mkl
		--enable-MMAP
		--enable-NewSolver
		--enable-pipe
		--enable-gsltest
		--enable-system_fftw
		--enable-system_blas
		$(use_enable umfpack system_umfpack)
		$(use_enable umfpack)
		$(use_with mpi)
		--with-arpack="$($(tc-getPKG_CONFIG) --libs arpack)"
		--with-blas="$($(tc-getPKG_CONFIG) --libs blas)"
		$(usex hdf5 "--with-hdf5=yes" "--with-hdf5=no")
		--disable-mumps_seq
		$(use_enable opengl)
		)

	if use opengl; then # use_with/usex might have issues with spaces in value
		my_ff_conf+=(--with-glut="$($(tc-getPKG_CONFIG) --cflags --libs glut)")
	else
		my_ff_conf+=(--without-glut)
	fi

	ff_use bemtool bemtool "${EPREFIX}/usr/include/bemtool" "${mpi_cxx_libs}"
	ff_use gmm gmm "${EPREFIX}/usr/include/gmm" ""
	ff_use hpddm hpddm "${EPREFIX}/usr/include/hpddm" "${mpi_cxx_libs}"
	ff_use htool htool "${EPREFIX}/usr/include/htool" \
		"${mpi_cxx_libs} $($(tc-getPKG_CONFIG) --libs blas lapack)"

	# each appends to args array
	ff_use_pc ipopt
	ff_use_pc lapack
	ff_use_pc metis
	ff_use mmg mmg "${EPREFIX}/usr/include/mmg" "-lmmg"
	ff_use mmg mmg3d "${EPREFIX}/usr/include/mmg/mmg3d" "-lmmg3d"
	ff_use parmmg parmmg "${EPREFIX}/usr/include/parmmg" "-lparmmg ${mpi_cxx_libs}"
	ff_use_pc mumps
	ff_use_pc nlopt
	ff_use_pc parmetis
	ff_use_pc scalapack
	ff_use_pc scotch
	ff_use_pc superlu
	ff_use tetgen tetgen "${EPREFIX}/usr/include" "-ltetgen"

	F77=$FC econf "${my_ff_conf[@]}" "${petsc_args[@]}"
	#bash -x ./configure "${my_ff_conf[@]}" "${petsc_args[@]}" 2>&1 | tee /tmp/config2.log
}

src_compile() {
	#export MAKEOPTS="-j1"

	# Woraround for compilation failure due to .deps dirs not created:
	# related to depcomp (generates -MF $$depbase.Po rules)
	local d
	for d in src/*/ src/*/*/ plugin/*/; do
		mkdir -p ${d}/.deps
	done

	default

	if use doc; then
		emake documentation
	fi
}

src_test() {
	if use mpi; then
		# This may depend on the used MPI implementation. It is needed
		# with mpich2, but should not be needed with lam-mpi or mpich
		# (if the system is configured correctly).
		ewarn "Please check that your MPI root ring is on before running"
		ewarn "the test phase. Failing to start it before that phase may"
		ewarn "result in a failing emerge."
		epause
	fi
	emake -j1 check
}

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

