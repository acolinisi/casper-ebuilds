# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )

inherit cmake python-any-r1

# Note: this package exists because sci-libs/parmmg needs an unreleased version
# The 4th element of version is number of commits relative to release branch:
#    git describe --long develop
MY_PV=$(ver_cut 1-3)
# newer than this one are incompatible
MY_COMMIT=f55cd2221a07a60dc7466c421c51402ef4a9c9f5 # v5.4.3-267-gf55cd222

DESCRIPTION="Bidimensional and tridimensional remeshing"
HOMEPAGE="
 	http://www.mmgtools.org
	https://github.com/MmgTools/mmg
	"
# See cmake/modules/LoadCiTests.cmake for test tarball IDs
SRC_URI="https://github.com/MmgTools/${PN}/archive/${MY_COMMIT}.tar.gz -> ${P}.tar.gz
		test? (
		gdrive://1Pren7-lwnkG7UTaUimspE-16hlIDLoCc -> ${PN}-test_mmg-0.0.13.tgz.aa
		gdrive://1CZJM__QvYq_88BcMb3dBtaY2nDRYrcLz -> ${PN}-test_mmg-0.0.13.tgz.ab
		gdrive://1NZHHeSmMzpiADGfLbTatbVn2bjv0bbVp -> ${PN}-test_mmg-0.0.13.tgz.ac
		gdrive://1Lnvh7AldwEXS7WRa1VxsRqI7Xu7CgJNj -> ${PN}-test_mmg2d-0.0.21.tgz
		gdrive://0B3X6EwOEKqHmcVdZb1EzaTR3ZlU -> ${PN}-test_mmgs-0.0.21.tgz
		gdrive://1WJK8mbFh81QFsDuOUt7kcavJwLO4yatO -> ${PN}-test_mmg3d-0.0.21.tgz.aa
		gdrive://1SvznS9n57f1jIVoeFMM7-WVGJUu3OdMz -> ${PN}-test_mmg3d-0.0.21.tgz.ab
		gdrive://1wACP1jut6Dz4mTf6uQARW7Koc1Zs_O9H -> ${PN}-test_mmg3d-0.0.21.tgz.ac
		gdrive://142BueykwzDGS_Ne_RzJfgMGqQNhzJb6a -> ${PN}-test_mmg3d-0.0.21.tgz.ad
		gdrive://1dEXKIApQiEkplI03bgVbThKMKTL4P0M_ -> ${PN}-test_mmg3d-0.0.21.tgz.ae
		gdrive://1KA5H7oS9HrtXT3sUpGU78YU7BwRHMVk7 -> ${PN}-test_mmg3d-0.0.21.tgz.af
		gdrive://1duHPrEjdHrb1k9VwoV_-uYw4CPbMN9AM -> ${PN}-test_mmg3d-0.0.21.tgz.ag
		gdrive://179k-asjM88ewVumZSQ9eUMWLJRfbQwIz -> ${PN}-test_mmg3d-0.0.21.tgz.ah
		gdrive://1yjGvVah-vFNhwsImrHA0Bu5sIo1Fo5wW -> ${PN}-test_mmg3d-0.0.21.tgz.ai
		gdrive://1PpQpC0OvJUTieTs0jd_A0Qb5EVP3QfZw -> ${PN}-test_mmg3d-0.0.21.tgz.aj
		gdrive://1DbI0CCIYvDX-cPLZehazMV5wmu-K9K4b -> ${PN}-test_mmg3d-0.0.21.tgz.ak
		gdrive://1MDALbXmXSpoVaHo4ghU6QpmQhsBP8Pjy -> ${PN}-test_mmg3d-0.0.21.tgz.al
		gdrive://1iil5UBwVgpcErUcKd_wJi_Oguuuyy0HT -> ${PN}-test_mmg3d-0.0.21.tgz.am
		)
		"

LICENSE="LGPL"
KEYWORDS="amd64 ~amd64-linux"
SLOT="0/$(ver_cut 1)"
IUSE="doc elas +delaunay +scotch index-64bit src static-libs test"

# TODO: option https://github.com/ISCDtoolbox/LinearElasticity
BDEPEND="
	doc? ( app-doc/doxygen[dot] )
	test? ( ${PYTHON_DEPS} $(python_gen_any_dep \
		'dev-python/gdown[${PYTHON_USEDEP}]')
		)
	"
RDEPEND="
	scotch? ( sci-libs/scotch[index-64bit=] )
	elas? ( sci-libs/elas )
	"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${PN}-${MY_COMMIT}"

PATCHES=(
	"${FILESDIR}"/${PN}-5.4.3-cmake-optional-doc.patch
	"${FILESDIR}"/${P}-cmake-test-gdown.patch
	"${FILESDIR}"/${P}-cmake-test-keep-files.patch
	"${FILESDIR}"/${P}-gcc-no-common.patch
	)

src_unpack() {
	local tarballs=(${A})
	unpack "${tarballs[0]}"
	tarballs[0]=""

	if use test; then
		# Join the parts as in cmake/modules/LoadCiTests.cmake
		local test_tarballs=()
		local test_mmg_parts=()
		local test_mmg3d_parts=()
		local t
		for t in ${tarballs[@]}; do
			if [[ "${t}" = ${PN}-test_mmg-*.tgz.* ]]; then
				test_mmg_parts+=("${t}")
			elif [[ "${t}" = ${PN}-test_mmg3d-*.tgz.* ]]; then
				test_mmg3d_parts+=("${t}")
			else
				test_tarballs+=("${t}")
			fi
		done
		local test_mmg_ver=$(echo ${test_mmg_parts[0]} | \
			sed "s/^${PN}-test_mmg-\([0-9.]\+\)\.tgz\..*/\1/")
		local test_mmg3d_ver=$(echo ${test_mmg3d_parts[0]} | \
			sed "s/^${PN}-test_mmg3d-\([0-9.]\+\)\.tgz\..*/\1/")

		pushd "${DISTDIR}"
		cat "${test_mmg_parts[@]}" > ${PN}-test_mmg-${test_mmg_ver}.tgz
		test_tarballs+=(${PN}-test_mmg-${test_mmg_ver}.tgz)
		cat "${test_mmg3d_parts[@]}" > ${PN}-test_mmg3d-${test_mmg3d_ver}.tgz
		test_tarballs+=(${PN}-test_mmg3d-${test_mmg3d_ver}.tgz)
		popd

		mkdir ${S}/ci_tests
		pushd ${S}/ci_tests
		unpack "${test_tarballs[@]}"
		popd
	fi
}

src_prepare() {
	cmake_src_prepare
	find . -name '*.c' -execdir sed -i \
		"s@^#include \"mmg\(2d\|3d\|s\)\?externs.c\"@@" {} \;
}

src_configure() {
	# BULD=MMG: compile all libraries
	local mycmakeargs=(
		-DBUILD=MMG
		-DBUILD_DOC=$(usex doc)
		-DLIBMMG2D_SHARED=ON
		-DLIBMMG3D_SHARED=ON
		-DLIBMMGS_SHARED=ON
		-DLIBMMG_SHARED=ON
		-DLIBMMG2D_STATIC=$(usex static-libs)
		-DLIBMMG3D_STATIC=$(usex static-libs)
		-DLIBMMGS_STATIC=$(usex static-libs)
		-DLIBMMG_STATIC=$(usex static-libs)
		-DUSE_ELAS=$(usex elas)
		-DUSE_SCOTCH=$(usex scotch)
		-DBUILD_TESTING=$(usex test)
		-DUPDATE_TESTS=OFF
		-DLONG_TESTS=OFF
		-DTEST_LIBMMG2D=$(usex test)
		-DTEST_LIBMMG3D=$(usex test)
		-DTEST_LIBMMGS=$(usex test)
		-DTEST_LIBMMG=$(usex test)
		-DCOVERAGE=OFF
		-DPROFILING=OFF
		-DPATTERN=$(usex delaunay "OFF" "ON")
	)
	cmake_src_configure
}

src_install() {
	cmake_src_install
	
	# TODO: create pkgconfig .pc files

	if use src; then
		# ParMmg requires not just installed headers, but the src and bld dirs
		insinto /usr/src/sci-libs/mmg
		doins -r src
		doins -r "${BUILD_DIR}"/src
		find "${ED}" -name '*.h.in' -delete
	fi
}
