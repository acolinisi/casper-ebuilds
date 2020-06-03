# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit fortran-2

MY_PN=cadna_c

DESCRIPTION="Control of Accuracy and Debugging for Numerical Applications"
HOMEPAGE="http://cadna.lip6.fr/index.php"
SRC_URI="http://cadna.lip6.fr/Download_Dir/${MY_PN}-${PV}.tar.gz"

LICENSE="LGPL"
KEYWORDS="amd64 ~amd64-linux"
SLOT="0/$(ver_cut 1)"
IUSE="fortran mpi +openmp test"

DEPEND="mpi? ( virtual/mpi )"
RDEPEND="${DEPEND}"

S="${WORKDIR}"/${MY_PN}-${PV}

#PATCHES=()

src_configure() {
	econf --includedir="${EPREFIX}/usr/include/${PN}" \
		$(use_enable fortran) $(use_enable openmp)
}

cadna_examples() {
	local examples=(examplesC)
	use openmp && examples+=(examplesC_omp)

	if use mpi; then
		examples+=(examplesC_mpi )
		use openmp && examples+=(examplesC_mpiomp)
	fi

	if use fortran; then
		examples+=(examplesFortran)
		use mpi && examples+=(examplesFortran_mpi)
	fi
	echo "${examples[@]}"
}

src_compile() {
	export MAKEOPTS=-j1 # see README (parallel indeed broken)

	local subdirs=(srcC)
	use mpi && subdirs+=(srcC_mpi)
	if use fortran; then
		subdirs+=(srcFortran)
		use mpi && subdirs+=(srcFortran_mpi)
	fi
	SUBDIRS="${subdirs[@]}" emake

	if use test; then
		# Temporarily install just for building tests
		local test_install="${S}"/_install
		local test_prefix="${test_install}/${EPREFIX}/usr"
		emake install DESTDIR="${test_install}"

		local ex libs
		for ex in $(cadna_examples)
		do
			case "${ex}" in
			  examplesFortran_mpi)
				  # The example is in Fortran so built with mpif90 but it
				  # links against the Fortran Cadna library that includes MPI
				  # bindings that were built with mpic++, hence add the C++
				  # MPI lib manually.
				  libs=(-lmpi_cxx)
			esac

			emake -C "${ex}" \
				CPPFLAGS+=" -I\"${test_prefix}/include/${PN}\" " \
				FCFLAGS+=" -J\"${test_prefix}/include/${PN}\" " \
				LDFLAGS+=" -L\"${test_prefix}/$(get_libdir)\" " \
				CFLAGS+=" ${CFLAGS}" CXXFLAGS+=" ${CXXFLAGS} " \
				LIBS+=" ${libs[@]} "
        done
	fi
}

src_test() {
	local ex launch_cmd bins
	for ex in $(cadna_examples)
	do
		case "${ex}" in
		  examplesC|examplesFortran)
			  bins=(ex1 ex1_cad ex2 ex2_cad ex3 ex3_cad
				ex4 ex4_cad ex5 ex5_cad ex5_cad_opt
				ex6 ex6_cad)
				# ex7 ex7_cad # these are interactive
				;;
		  examplesC_mpi)
			  launch_cmd="mpirun -np 4" # num procs required by tests
			  bins=(exampleMPI1 exampleMPI1_cad
					exampleMPI2 exampleMPI2_cad
					exampleMPI1_float exampleMPI1_float_cad
					exampleMPI2_float exampleMPI2_float_cad) ;;
		  examplesC_mpiomp)
			  bins=(exampleMPI_OMP1 exampleMPI_OMP1_cad) ;;
		  examplesC_omp)
			  bins=(exampleOPENMP1 exampleOPENMP1_cad) ;;
		  examplesFortran_mpi)
				launch_cmd="mpirun -np 4" # num procs required by tests
				bins=(exampleMPI1Reduce_cad
					exampleMPI1Reduce_float_cad
					exampleMPI1SendRecv exampleMPI1SendRecv_float
					exampleMPI1SendRecv_cad
					exampleMPI1SendRecv_float_cad) ;;
		esac

		for bin in "${bins[@]}"
		do
				${launch_cmd} ./${ex}/${bin} || die
		done
	done
}

src_install() {
	default
	dodoc doc/*.pdf
}
