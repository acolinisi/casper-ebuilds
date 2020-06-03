# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )

inherit fortran-2 python-single-r1 toolchain-funcs

MY_COMMIT=7970a4cf323c7d9602e8d29bad8d64654a808156

DESCRIPTION="A framework for high-performance domain decomposition methods"
HOMEPAGE="https://github.com/hpddm/hpddm"
SRC_URI="https://github.com/hpddm/${PN}/archive/${MY_COMMIT}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-3"
KEYWORDS="amd64 ~amd64-linux"
SO_VER=0
SLOT="0/${PV}" # no semantic versining, so rebuild on all changes
IUSE="c fortran hypre index-64bit mumps pastix python scalapack suitesparse test"

REQUIRED_USE="python?  ( ${PYTHON_REQUIRED_USE} )
	^^ ( hypre mumps suitesparse pastix )
	"

# TODO: mkl paradiso, elemental, dissection (subsolver), feast (eigen)
# TODO: libxsmm
# TODO: slepc? ( sci-libs/slepc[index-64bit=,complex-scalars=] )
#       is slepc an alternative to arpack?
MY_DEPEND="
	virtual/blas
	virtual/lapack
	virtual/mpi
	sci-libs/arpack
	scalapack? ( sci-libs/scalapack )
	hypre? ( <sci-libs/hypre-2.18[index-64bit=] )
	mumps? ( sci-libs/mumps[index-64bit=] )
	suitesparse? ( sci-libs/umfpack[cholmod] sci-libs/cholmod )
	pastix? ( <sci-libs/pastix-6[index-64bit=] )
	"
MY_PY_DEPEND="
	python? ( ${PYTHON_DEPS} $(python_gen_cond_dep \
		'
		dev-python/mpi4py[${PYTHON_MULTI_USEDEP}]
		dev-python/numpy[${PYTHON_MULTI_USEDEP}]
		')
	)
	"
# The library deps need to be installed only if building language interfaces
# or tests. Otherwise, nothing to build: only headers are installed.
BDEPEND="python? ( test? ( ${MY_PY_DEPEND} ) )"
DEPEND="
	c? ( ${MY_DEPEND} )
	fortran? ( ${MY_DEPEND} )
	python? ( ${MY_DEPEND} )
	test? ( ${MY_DEPEND} )
	"
RDEPEND="${MY_DEPEND}
	python? ( ${MY_PY_DEPEND} )
	"

S="${WORKDIR}"/${PN}-${MY_COMMIT}

PATCHES=(
	"${FILESDIR}"/${P}-fortran.patch
	"${FILESDIR}"/${P}-soname.patch
	)

src_configure() {
	# only one of each should be set
	local solver="\
		$(usex hypre HYPRE "") \
		$(usex mumps MUMPS "") \
		$(usex pastix PASTIX "") \
		$(usex suitesparse SUITESPARSE "")"

	# TODO: add to eigensolver list? $(usex slepc SLEPC)

	# took Make.inc/Makefile.Linux as base
	# TODO: BLAS_INCS (for Lapack? )
	cat <<-EOF > Makefile.inc
	SOLVER ?= $(echo ${solver})
	SUBSOLVER ?= $(echo ${solver})
	EIGENSOLVER ?= ARPACK

	MPICXX ?= mpic++
	MPICC ?= mpicc
	MPIF90 ?= mpif90
	MPIRUN ?= mpirun -np

	override CXXFLAGS += -std=c++11 -fPIC ${CXXFLAGS}
	override CFLAGS += -std=c99 -fPIC ${CFLAGS}

	HPDDMFLAGS ?= -DHPDDM_NUMBERING=\'C\'
	SO_VER = 0

	BLAS_LIBS = $($(tc-getPKG_CONFIG) --libs blas lapack)

	ARPACK_INCS = $($(tc-getPKG_CONFIG) --cflags arpack)
	ARPACK_LIBS = $($(tc-getPKG_CONFIG) --libs arpack)
	EOF

	if use hypre; then
		cat <<-EOF >> Makefile.inc
		HYPRE_INCS = $($(tc-getPKG_CONFIG) --cflags hypre)
		HYPRE_LIBS = $($(tc-getPKG_CONFIG) --libs hypre)
		EOF
	fi

	if use mumps; then
		cat <<-EOF >> Makefile.inc
		MUMPS_INCS = $($(tc-getPKG_CONFIG) --cflags mumps)
		MUMPS_LIBS = $($(tc-getPKG_CONFIG) --libs mumps)
		EOF
	fi

	if use pastix; then
		cat <<-EOF >> Makefile.inc
		PASTIX_INCS = $($(tc-getPKG_CONFIG) --cflags pastix)
		PASTIX_LIBS = $($(tc-getPKG_CONFIG) --libs pastix)
		EOF
	fi

	if use scalapack; then
		cat <<-EOF >> Makefile.inc
		SCALAPACK_INCS = $($(tc-getPKG_CONFIG) --cflags scalapack)
		SCALAPACK_LIBS = $($(tc-getPKG_CONFIG) --libs scalapack)
		EOF
	fi

	if use suitesparse; then
		cat <<-EOF >> Makefile.inc
		SUITESPARSE_INCS =
		SUITESPARSE_LIBS = -lumfpack -lcholmod
		EOF
	fi

	if use python; then
		local pyver=$(ver_cut 1-2 $(python --version | sed 's/Python\s*//'))
		cat <<-EOF >> Makefile.inc
		PYTHON_INCS = $($(tc-getPKG_CONFIG) --cflags python-${pyver})
		PYTHON_LIBS = $($(tc-getPKG_CONFIG) --libs python-${pyver})
		EOF
	fi
}

src_compile() {
	# for cpp it's header-only
	emake cpp \
		$(usex c c "") \
		$(usex python python "") \
		$(usex fortran fortran "")
}

src_test() {
	emake test_cpp \
		$(usex c test_c "") \
		$(usex fortran test_fortran "")

	# TODO: python tests broken
	# $(usex python test_python "")
}

src_install() {
	# Upstream does not provide an install target
	doheader -r include
	mv "${ED}"/usr/include/{include,${PN}} || die

	local lang
	for lang in c fortran python; do
		if use ${lang}; then
		   newlib.so lib/lib${PN}_${lang}.so lib${PN}_${lang}.so.${SO_VER}.${PV}
		   dosym lib${PN}_${lang}.so.${SO_VER}.${PV} \
			   /usr/$(get_libdir)/lib${PN}_${lang}.so.${SO_VER}
		   dosym lib${PN}_${lang}.so.${SO_VER} \
			   /usr/$(get_libdir)/lib${PN}_${lang}.so
		fi
	done

	use python && python_setup && python_domodule interface/hpddm.py

	dodoc -r doc/*.txt doc/*.pdf
}
