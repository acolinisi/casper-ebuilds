# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Check metis version bundled in parmetis tar ball
# by diff of metis and parmetis tar ball
METISPV=5.1.0
METISP=metis-${METISPV}
inherit cmake toolchain-funcs

DESCRIPTION="Parallel (MPI) unstructured graph partitioning library"
HOMEPAGE="http://www-users.cs.umn.edu/~karypis/metis/parmetis/"
SRC_URI="
	http://glaros.dtc.umn.edu/gkhome/fetch/sw/${PN}/${P}.tar.gz
	doc? ( http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/${METISP}.tar.gz )
	examples? ( http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/${METISP}.tar.gz )"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="amd64 arm64 x86 ~amd64-linux ~x86-linux"
IUSE="doc double-precision examples index-64bit mpi openmp pcre static-libs"
RESTRICT="mirror bindist"

DEPEND="mpi? ( virtual/mpi )"
RDEPEND="${DEPEND}
	!<sci-libs/metis-5"

pkg_setup() {
	if use openmp; then
		if [[ $(tc-getCC)$ == *gcc* ]] && ! tc-has-openmp; then
			ewarn "You are using gcc but openmp is not available"
			die "Need an OpenMP capable compiler"
		fi
	fi
}

src_prepare() {
	cmake_src_prepare

	# libdir love
	sed -i \
		-e '/DESTINATION/s/lib/lib${LIB_SUFFIX}/g' \
		libparmetis/CMakeLists.txt metis/libmetis/CMakeLists.txt || die
	# set metis as separate shared lib
	sed -i \
		-e 's/METIS_LIB/ParMETIS_LIB/g' \
		metis/libmetis/CMakeLists.txt || die
	sed -i \
		-e '/programs/d' \
		CMakeLists.txt metis/CMakeLists.txt || die
	if use static-libs; then
		mkdir "${WORKDIR}/${PN}_static" || die
	fi

	if use mpi; then
		export CC=mpicc CXX=mpicxx
	else
		sed -i \
			-e '/add_subdirectory(include/d' \
			-e '/add_subdirectory(libparmetis/d' \
			CMakeLists.txt || die
	fi

	if use index-64bit; then
		sed -i -e '/define\s\+IDXTYPEWIDTH/s/32/64/' metis/include/metis.h || die
	fi

	if use double-precision; then
		sed -i -e '/define\s\+REALTYPEWIDTH/s/32/64/' metis/include/metis.h || die
	fi
}

src_configure() {
	parmetis_configure() {
		local mycmakeargs=(
			-DGKLIB_PATH="${S}/metis/GKlib"
			-DMETIS_PATH="${S}/metis"
			-DCMAKE_SKIP_BUILD_RPATH=ON
			-DCMAKE_BUILD_WITH_INSTALL_RPATH=OFF
			-DCMAKE_INSTALL_RPATH_USE_LINK_PATH=OFF
			-DGKRAND=ON
			-DMETIS_INSTALL=ON
			-DOPENMP=$(usex openmp)
			-DPCRE=$(usex pcre)
			$@
		)
		cmake_src_configure
	}
	parmetis_configure -DSHARED=ON
	if use static-libs; then
		sed -i -e '/fPIC/d' metis/GKlib/GKlibSystem.cmake || die
		BUILD_DIR="${WORKDIR}/${PN}_static" parmetis_configure
	fi
}

src_compile() {
	cmake_src_compile
	use static-libs && \
		BUILD_DIR="${WORKDIR}/${PN}_static" cmake_src_compile
}

src_install() {
	cmake_src_install
	use static-libs && \
		BUILD_DIR="${WORKDIR}/${PN}_static" cmake_src_install
	insinto /usr/include
	doins metis/include/metis.h

	newdoc metis/Changelog Changelog.metis}
	use doc && dodoc "${WORKDIR}/${METISP}"/manual/manual.pdf
	if use examples; then
		insinto /usr/share/doc/${PF}/examples/metis
		doins "${WORKDIR}/${METISP}"/{programs,graphs}/*
	fi
	# alternative stuff
	cat > metis.pc <<-EOF
		Name: metis
		Description: Unstructured graph partitioning library
		Version: ${METISPV}
		URL: ${HOMEPAGE/parmetis/metis}
		Libs: -lmetis
	EOF
	insinto /usr/$(get_libdir)/pkgconfig
	doins metis.pc
	# change if scotch is actually an alternative to metis
	#alternatives_for metis metis 0 \
	#	/usr/$(get_libdir)/pkgconfig/metis.pc refmetis.pc

	if use mpi; then
		dodoc Changelog
		use doc && dodoc manual/manual.pdf
		if use examples; then
			insinto /usr/share/doc/${PF}/examples/${PN}
			doins {programs,Graphs}/*
		fi
		# alternative stuff
		cat > ${PN}.pc <<-EOF
			Name: ${PN}
			Description: ${DESCRIPTION}
			Version: ${PV}
			URL: ${HOMEPAGE}
			Libs: -l${PN}
			Requires: metis
		EOF
		insinto /usr/$(get_libdir)/pkgconfig
		doins ${PN}.pc
		# change if scotch is actually an alternative to parmetis
		#alternatives_for metis-mpi ${PN} 0 \
		#	/usr/$(get_libdir)/pkgconfig/metis-mpi.pc ${PN}.pc
	fi
}
