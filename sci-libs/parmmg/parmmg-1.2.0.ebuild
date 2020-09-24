# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake

MY_PN=ParMmg

DESCRIPTION="Parallel mesh adaptation of #D volume meshes."
HOMEPAGE="
 	http://www.mmgtools.org
	https://github.com/MmgTools/ParMmg
	"
SRC_URI="https://github.com/MmgTools/${MY_PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL"
KEYWORDS="amd64 ~amd64-linux"
SLOT="0/$(ver_cut 1)"
IUSE="doc scotch index-64bit test vtk"


BDEPEND="doc? ( app-doc/doxygen[dot] )"
RDEPEND="
	virtual/mpi
	<=sci-libs/mmg-5.4.3.267[scotch=,index-64bit=,src]
	!>sci-libs/mmg-5.4.3.267
	!<sci-libs/mmg-5.4.3
	sci-libs/parmetis[-index-64bit]
	scotch? ( sci-libs/scotch[index-64bit=] )
	vtk? ( sci-libs/vtk )
	"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${MY_PN}-${PV}"

PATCHES=(
	"${FILESDIR}"/${P}-cmake-optional-libs.patch
	"${FILESDIR}"/${P}-cmake-optional-doc.patch
	"${FILESDIR}"/${P}-cmake-libdir.patch
	"${FILESDIR}"/${P}-cmake-cross-compile.patch
	)

src_configure() {
	# Requires MMG sources and even build dir, besides public headers
	# static and shared are exclusive, so choose shared
	local mmg_src="${EPREFIX}/usr/src/sci-libs/mmg"
	local mycmakeargs=(
		# CROSS_COMPILNG set by profile (see comments there)
		-DCROSS_COMPILING=${CROSS_COMPILING}
		-DDOWNLOAD_METIS=OFF
		-DDOWNLOAD_MMG=OFF
		-DBUILD_TESTING=$(usex test)
		-DBUILD_DOC=$(usex doc)
		-DLIBPARMMG_SHARED=ON
		-DLIBPARMMG_STATIC=OFF
		-DUSE_SCOTCH=$(usex scotch)
		-DUSE_VTK=$(usex vtk)
		-DMMG_INCDIR="${EPREFIX}/usr/include/mmg"
		-DMMG_LIBDIR="${EPREFIX}/usr/$(get_libdir)"
		-DMMG_DIR="${mmg_src}"
		-DPROFILING=OFF
	)
	cmake_src_configure
}

#src_install() {
#	default
#
#	# ugly, but needed for consumers might not be compiling with mpi wrapper
#	# (sci-mathematics/freefem++)
#	if has_version sys-cluster/openmpi; then
#		mpi_cxx_libs="$($(tc-getPKG_CONFIG) --libs ompi-cxx)"
#	else
#		die "no supported mpi implementation found"
#	fi
#
#	cat <<-EOF > ${PN}.pc
#	prefix=${EPREFIX}/usr
#	libdir=\${prefix}/$(get_libdir)
#	Name: ${PN}
#	Description: ${DESCRIPTION}
#	Version: ${PV}
#	URL: ${HOMEPAGE}
#	Libs: -L\${libdir} -lparmmg
#	Cflags: -I\${prefix}/include/${PN}/metis
#	Requires: mmg
#	EOF
#}
