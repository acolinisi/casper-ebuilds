# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )

inherit flag-o-matic fortran-2 python-any-r1 toolchain-funcs

DESCRIPTION="Portable, Extensible Toolkit for Scientific Computation"
HOMEPAGE="http://www.mcs.anl.gov/petsc/"
SRC_URI="http://ftp.mcs.anl.gov/pub/petsc/release-snapshots/${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="~amd64 ~amd64-linux ~x86"
#TODO: cuda, openmp, ml,  trilinos
# TODO: mkl_[c]paradiso, mkl_sparse, adblaslapack, comblas, c
#TODO: eigen, mfem, moab, party, samrai, silo, triangle, exodusii, alquimia, pflotran, amazi, mstk, ascem-io, cgns, ctetgen, egads, elemental, moose, sundials, tchem
#TODO: unittestcpp,  oncurrencykit,  giflib, glut, gmp, googletest
#TODOO: lgrind, libceed, libjpeg, libmesh, libpng, med, memkind, mpe, mpfr, mpi4pi, muparser, opencl, opengles, p4est, parms, pami, petsc4py, pragmatic, radau5, revolve, saws, sowing, spai, sprint, ssl, strumpack,  valgrind, viennacl, xsdktilinos, yaml, zstd, slepc (???)
# TODO: chaco (mesh partitioning)
IUSE="afterimage boost complex-scalars cxx debug doc eigen fftw
	fortran hdf5 hpddm hwloc hypre index-64bit mpi metis mumps parmetis pastix scotch sparse
	superlu superlu_dist tetgen threads X"

# hypre and superlu curretly exclude each other due to missing linking to hypre
# if both are enabled
# enabling parmetis but not metis is rejected by the configure script
# SuperLU does not support 64-bit indices, use SuperLU_DIST for with index-64bit.
REQUIRED_USE="
	afterimage? ( X )
	complex-scalars? ( !hypre !superlu )
	hdf5? ( mpi )
	hypre? ( cxx mpi !superlu )
	mumps? ( mpi )
	parmetis? ( metis )
	pastix? ( hwloc )
	scotch? ( mpi )
	superlu? ( !hypre )
	index-64bit? ( !superlu )
"

# TODO: depend on openblas and blis directly?
# TODO: --with-hpddm=0 attempts to make hpddm-install target and fails
RDEPEND="
	|| ( virtual/blas sci-libs/blis[index-64bit] )
	virtual/lapack
	afterimage? ( media-libs/libafterimage )
	boost? ( dev-libs/boost )
	fftw? ( sci-libs/fftw:3.0[mpi?] )
	eigen? ( dev-cpp/eigen )
	hdf5? ( sci-libs/hdf5[mpi?] )
	hpddm? ( sci-libs/hpddm )
	hypre? ( >=sci-libs/hypre-2.18.0[mpi?,index-64bit=] )
	parmetis? ( >=sci-libs/parmetis-4[index-64bit=] )
	!parmetis? ( metis? ( sci-libs/metis ) )
	mpi? ( virtual/mpi[fortran?] )
	mumps? ( sci-libs/mumps[mpi?] sci-libs/scalapack )
	pastix? ( >=sci-libs/pastix-5[index-64bit=] )
	scotch? ( sci-libs/scotch[mpi?,index-64bit=] )
	sparse? ( >=sci-libs/suitesparse-5.6.0 >=sci-libs/cholmod-1.7.0 )
	superlu? ( >=sci-libs/superlu-5:= )
	superlu_dist? ( >=sci-libs/superlu_dist-6:0=[index-64bit=] )
	tetgen? ( sci-libs/tetgen )
	X? ( x11-libs/libX11 )
"

BDEPEND="
	virtual/pkgconfig
	dev-util/cmake
	"
DEPEND="${RDEPEND}
	${PYTHON_DEPS}
"

# note: a sed-patch in src_prepare
# TODO: part of pastix v6 patch (IPARM_SYM -> IPARM_MTX_TYPE) should be a patch
# to pastix's old_api.h
PATCHES=(
	"${FILESDIR}"/${PN}-3.13.0-fix_sandbox_violation.patch
	"${FILESDIR}"/${PN}-3.13.0-do_not_run_mpiexec.patch
	"${FILESDIR}"/${PN}-3.13.0-lowercase-pkgname.patch
	"${FILESDIR}"/${PN}-3.13.0-pkgconfig-split.patch
	"${FILESDIR}"/${PN}-3.13.0-pastix-v6-via-v5-compat.patch
	"${FILESDIR}"/${PN}-3.13.0-pastix-params.patch
	"${FILESDIR}"/${PN}-3.13.0-pastix-comm-type.patch
	"${FILESDIR}"/${PN}-3.13.0-pastix-refine.patch
)
	#"${FILESDIR}"/${PN}-pkgconfig.patch
	#"${FILESDIR}"/${PN}-3.13.0-install_prefix.patch

MAKEOPTS="${MAKEOPTS} V=1"

src_prepare() {
	default

	# rename happened in SuperLU_DIST between 6.3.0 -> 6.3.1 (*sigh*)
	find src/mat/impls/aij/mpi/superlu_dist/ -type f \
		-execdir sed -i -e 's/LargeDiag_AWPM/LargeDiag_HWPM/g' {} \;
}

#src_prepare() {
#	default
#
#	sed -i -e 's%/usr/bin/env python%/usr/bin/env python2%' configure || die
#}

# petsc uses --with-blah=1 and --with-blah=0 to en/disable options
petsc_enable() {
	use "$1" && echo "--with-${2:-$1}=1" || echo "--with-${2:-$1}=0"
}
# add external library:
# petsc_with use_flag libname libdir
# petsc_with use_flag libname include linking_libs
petsc_with() {
	local myuse p=${2:-${1}}
	if use ${1}; then
		myuse="--with-${p}=1"
		if [[ $# -ge 4 ]]; then
			myuse="${myuse} --with-${p}-include=${EPREFIX}${3}"
			shift 3
			myuse="${myuse} --with-${p}-lib=$@"
		else
			myuse="${myuse} --with-${p}-dir=${EPREFIX}${3:-/usr}"
		fi
	else
		myuse="--with-${p}=0"
	fi
	echo ${myuse}
}

petsc_join() { local IFS="$1"; shift; echo "$*"; }
petsc_check_spaces() { # because can't return strings with spaces from funcs
	echo "${1}" | grep '\S\s\+\S' && die "spaces in path"
}

# petsc_with_pcdir use_flag [libname [pkgconfig_dir]]
petsc_with_pcdir() {
	local p=${2:-${1}}
	local pcdir="${3:-${EPREFIX}/usr/$(get_libdir)/pkgconfig}"
	if use ${1}; then
		petsc_check_spaces "${pcdir}"
		echo "--with-${p}=1 --with-${p}-pkg-config=${pcdir}"
	else
		echo "--with-${p}=0"
	fi
}

# When the case in filename.pc (e.g. PaStiX.pc) used by PETSc doesn't
# match ours, we cannot use petsc_with_pcdir, so call pkgconfig ourselves
# petsc_with_pc use_flag [libname]
#petsc_with_pc() {
#	if use ${1}; then
#		local p=${2:-${1}}
#		#local incdirs="[$($(tc-getPKG_CONFIG) --cflags ${p} | \
#		#	sed -e 's/-I//g' -e 's/^\s\+//' -e 's/\s\+$//' \
#		#		-e 's/\s\+/,/')]"
#		#local libs="[$($(tc-getPKG_CONFIG) --libs ${p} | \
#		#	sed -e 's/^\s\+//' -e 's/\s\+$//' -e 's/\s\+/,/')]"
#		local incdirs="[$(petsc_join , \
#			$($(tc-getPKG_CONFIG) --cflags ${p} | \
#			sed -e 's/-I//g'))]"
#		local libs="[$(petsc_join , \
#			$($(tc-getPKG_CONFIG) --libs ${p}))]"
#		echo "--with-${p}-lib=${libs} --with-${p}-include=${incdirs}"
#	fi
#}
# If pkgconfig.patch applied, then don't need the above
petsc_with_pc() {
	petsc_with_pcdir "$@"
}

# select between configure options depending on use flag
petsc_select() {
	use "$1" && echo "--with-$2=$3" || echo "--with-$2=$4"
}

src_configure() {
	# bug 548498
	# PETSc runs mpi processes during configure that result in a sandbox
	# violation by trying to open /proc/mtrr rw. This is not easy to
	# mitigate because it happens in libpciaccess.so called by libhwloc.so,
	# which is used by libmpi.so.
	addpredict /proc/mtrr
	# if mpi is built with knem support it needs /dev/knem too
	addpredict /dev/knem

	# configureMPITypes with openmpi-2* insists on accessing the scaling
	# governor rw.
	addpredict /sys/devices/system/cpu/

	local mylang
	local myopt

	use cxx && mylang="cxx" || mylang="c"
	use debug && myopt="debug" || myopt="opt"

	# environmental variables expected by petsc during build

	export PETSC_DIR="${S}"
	export PETSC_ARCH="linux-gnu-${mylang}-${myopt}"

	if use debug; then
		strip-flags
		filter-flags -O*
	fi

	# C Support on CXX builds is enabled if possible i.e. when not using
	# complex scalars (no complex type for both available at the same time)

		#$(petsc_with scotch ptscotch \
		#	/usr/include/scotch \
		#[-lptesmumps,-lptscotch,-lptscotcherr,-lscotch,-lscotcherr]) 
	# TODO: mumps.pc pkgconfig in mumps pkg
	#$(usex index-64bit --known-64-bit-blas-indices) \
	#$(use_with blas-index-64bit 64-bit-blas-indices) \
	#$(petsc_with superlu superlu \
	#	/usr/include/superlu -lsuperlu) \
	#$(petsc_with superlu_dist superlu_dist \
		#/usr/include/superlu_dist -lsuperlu_dist) \
	#$(petsc_with mumps scalapack \
	#/usr/include/scalapack -lscalapack) \
	#$(petsc_with mumps mumps \
	#	/usr/include \
	#	[-lcmumps,-ldmumps,-lsmumps,-lzmumps,-lmumps_common,-lpord]) \
		#$(petsc_with hypre hypre \
		#	/usr/include/hypre -lHYPRE) \
	#--with-blas-lapack-lib="$($(tc-getPKG_CONFIG) --libs blas lapack)" \
	econf \
		scrollOutput=1 \
		FFLAGS="${FFLAGS} -fPIC" \
		CFLAGS="${CFLAGS} -fPIC" \
		CXXFLAGS="${CXXFLAGS} -fPIC" \
		FCFLAGS="${FCFLAGS} -fPIC" \
		LDFLAGS="${LDFLAGS}" \
		--prefix="${EPREFIX}/usr/$(get_libdir)/petsc" \
		--with-shared-libraries \
		--with-single-library \
		$(petsc_enable debug debugging) \
		$(use cxx && ! use complex-scalars && echo "with-c-support=1") \
		--with-petsc-arch=${PETSC_ARCH} \
		--with-precision=double \
		$(use_with index-64bit 64-bit-indices) \
		--with-gnu-compilers \
		$(petsc_enable mpi) \
		$(petsc_select mpi cc mpicc $(tc-getCC)) \
		$(petsc_select mpi cxx mpicxx $(tc-getCXX)) \
		$(petsc_enable fortran) \
		$(use fortran && echo "$(petsc_select mpi fc mpif77 $(tc-getF77))") \
		$(petsc_enable mpi mpi-compilers) \
		$(petsc_select complex-scalars scalar-type complex real) \
		--with-windows-graphics=0 \
		--with-matlab=0 \
		--with-cmake:BOOL=1 \
		--with-imagemagick=0 \
		--with-python=0 \
		$(petsc_enable threads pthread) \
		--with-blaslapack=2 \
		--with-blaslapack-pkgconfig="${EPREFIX}/usr/$(get_libdir)/pkgconfig" \
		$(use_with boost) \
		$(petsc_with_pcdir fftw fftw3) \
		$(petsc_with afterimage afterimage \
			/usr/include/libAfterImage -lAfterImage) \
		$(petsc_with_pcdir eigen eigen "${EPREFIX}/usr/share/pkgconfig") \
		$(use_with hdf5) \
		$(petsc_with_pcdir hwloc) \
		$(petsc_with_pcdir hypre) \
		$(use_with metis) \
		$(petsc_with_pc mumps) \
		$(use_with parmetis) \
		$(petsc_with_pc pastix) \
		$(petsc_with_pcdir mumps scalapack) \
		$(use_with sparse suitesparse) \
		$(petsc_with_pc superlu) \
		$(petsc_with_pc superlu_dist) \
		$(petsc_with tetgen tetgen "${EPREFIX}"/usr/include -ltet) \
		$(use_with X x) \
		$(use_with X x11) \
		$(petsc_with_pc scotch ptscotch)

		#$(petsc_with hpddm hpddm "${EPREFIX}"/usr/include/hpddm "") 
}

src_install() {
	#emake DESTDIR="${ED}" DESTPREFIX="/usr/$(get_libdir)/petsc" install
	#dodir /usr/$(get_libdir)/petsc
	emake DESTDIR="${D}" install

	# add PETSC_DIR to environmental variables
	cat >> 99petsc <<- EOF
		PETSC_DIR=${EPREFIX}/usr/$(get_libdir)/petsc
		LDPATH=${EPREFIX}/usr/$(get_libdir)/petsc/lib
	EOF
	doenvd 99petsc

	if use doc ; then
		docinto html
		dodoc -r docs/*.html docs/changes docs/manualpages
	fi
}
