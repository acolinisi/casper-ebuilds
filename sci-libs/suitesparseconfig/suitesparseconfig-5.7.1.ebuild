# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

SUITESPARSE_VER=5.7.1
SUITESPARSE_COMP=SuiteSparse_config

inherit suitesparse

DESCRIPTION="Common configurations for all packages in suitesparse"
#HOMEPAGE="http://faculty.cse.tamu.edu/davis/suitesparse.html"
#SRC_URI="https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/v${PV}.tar.gz -> suitesparse-${PV}.tar.gz"
#S="${WORKDIR}/SuiteSparse-${PV}/SuiteSparse_config"

# Upstream says, "no licensing restrictions apply to this file or to the
# SuiteSparse_config directory".
LICENSE="public-domain"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~amd64-linux ~x86-linux ~x86-macos"
#IUSE="static-libs"

PATCHES=(
	"${FILESDIR}/${P}-rpath.patch"
	)
#"${FILESDIR}/${P}-eselect-blas.patch"

#src_compile() {
#	MAKEFLAGS+=" LDFLAGS_RPATH=" suitesparse_src_compile
#}

src_install() {
	LIB_DIR=. suitesparse_src_install
	insinto /usr/share/${PN}/
	doins SuiteSparse_config.mk
}

#TMP_DEST=${T}/dest

#src_configure() {
#	true
#}
#
#src_compile() {
#	# Upstream Makefile doesn't separate static/shared and build/install
#	# into targets well, so invoke target that builds and installs both.
#	emake LDFLAGS_RPATH= \
#		INSTALL_INCLUDE="${ED}"/include \
#		INSTALL_LIB="${ED}"/$(get_libdir) \
#		INSTALL_DOC="${TMP_DEST}"/doc install
#
#	if ! use static-libs; then
#		find "${ED}" -name "*.a" -delete || die
#	fi
#
#	# Can't install into TMP_DEST because that breaks -rpath, but also
#	# can't leave in ${ED} because portage clears it before install.
#	cp -a "${ED}"/. ${TMP_DEST}/
#}
#
#src_install() {
#	mkdir -p "${ED}"/usr/
#	cp -a "${TMP_DEST}"/{$(get_libdir),include} "${ED}"/usr/ || die
#	dodoc -r "${TMP_DEST}"/doc
#}
