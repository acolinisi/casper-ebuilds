# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake cuda fortran-2

MY_PN=SuperLU_DIST
MY_PV=$(ver_cut 1-3)

DESCRIPTION="MPI distributed sparse LU factorization library"
HOMEPAGE="https://portal.nersc.gov/project/sparse/superlu/#superlu_dist"
SRC_URI="https://portal.nersc.gov/project/sparse/superlu/${PN}_${MY_PV}.tar.gz"

LICENSE="BSD"
SLOT="cuda/$(ver_cut 1)"
KEYWORDS="~amd64 ~amd64-linux"
# TODO: double-precision (sci-libs/parmetis has a flag like that)
IUSE="doc examples fortran index-64bit lapack openmp parmetis static-libs test"

#TODO: cuda
#TODO: CombBLAS
BDEPEND="virtual/pkgconfig"
RDEPEND="
	virtual/blas
	virtual/mpi
	dev-util/nvidia-cuda-toolkit
	lapack? ( virtual/lapack )
	parmetis? ( sci-libs/parmetis[index-64bit?] )
	"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${MY_PN}_${MY_PV}"

PATCHES=("${FILESDIR}"/${PN}-${MY_PV}-cmake-mpi.patch)

src_prepare() {
	cmake_src_prepare
	cuda_src_prepare
}

src_configure() {
	local mycmakeargs+=(
		-DCMAKE_INSTALL_INCLUDEDIR="include/${PN}_cuda"
		-DBUILD_SHARED_LIBS=ON
		-DBUILD_STATIC_LIBS=$(usex static-libs)
		-DTPL_ENABLE_BLASLIB=OFF
		-DTPL_ENABLE_LAPACKLIB=$(usex lapack)
		-DTPL_ENABLE_PARMETISLIB=$(usex parmetis)
		-DTPL_ENABLE_COMBBLASLIB=OFF
		-Denable_double=ON
		-Denable_complex16=ON
		-Denable_openmp=$(usex openmp)
		-Denable_tests=$(usex test)
		-Denable_doc=$(usex doc)
		-Denable_examples=$(usex examples)
		-Denable_fortran=$(usex fortran)
		-DXSDK_INDEX_SIZE=$(usex index-64bit 64 32)
	)
	if use parmetis; then
		# note: can't let include dirs be empty
		mycmakeargs+=(
			-DTPL_PARMETIS_LIBRARIES="$($(tc-getPKG_CONFIG) --libs parmetis)"
			-DTPL_PARMETIS_INCLUDE_DIRS="$($(tc-getPKG_CONFIG) --cflags parmetis | \
				sed -e 's/-I//g' -e 's/\s\+/;/g' -e "s@^\s*\$@${EPREFIX}/usr/include@")"
		)
	fi
	# TODO: FindCUDA.cmake
	# TODO: try without
	local cuda_dir="${EPREFIX}/opt/cuda/targets/x86_64-linux"
	mycmakeargs+=(
		-DCMAKE_C_FLAGS="${CFLAGS} -DGPU_ACC -I${cuda_dir}/include"
		-DCMAKE_SHARED_LINKER_FLAGS="-L${cuda_dir}/lib -lcublas -lcudart"
	)

	cmake_src_configure
}

src_install() {
	cmake_src_install

	mv "${ED}"/usr/$(get_libdir)/lib${PN}{,_cuda}.so.$(ver_cut 1-3) || die

	rm "${ED}"/usr/$(get_libdir)/lib${PN}.so{,.$(ver_cut 1)} || die
	dosym lib${PN}_cuda.so.$(ver_cut 1-3)  /usr/$(get_libdir)/lib${PN}_cuda.so.$(ver_cut 1)
	dosym lib${PN}_cuda.so.$(ver_cut 1) /usr/$(get_libdir)/lib${PN}_cuda.so

	mv "${ED}"/usr/$(get_libdir)/pkgconfig/{${PN}.pc,${PN}_cuda.pc} || die

	insinto "/usr/share/eselect/modules"
	doins ${FILESDIR}/${PN}.eselect

	use doc && dodoc -r DOC/html
	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r EXAMPLE FORTRAN
		docompress -x /usr/share/doc/${PF}/examples
	fi
}

pkg_postinst() {
	"${EROOT}"/usr/bin/eselect $PN set superlu_dist_cuda
}
