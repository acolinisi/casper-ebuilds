# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: suitesparse.eclass
# @MAINTAINER:
# Alexei Colin <ac@alexeicolin.com>
# @BLURB: Build components of SuiteSparse

# @ECLASS-VARIABLE: SUITESPARSE_VER
# @REQUIRED
# @DESCRIPTION:
# Version of the SuiteSparse software distribution from which
# to get the component. This version may differ among the
# various components (e.g. if a new suite is released where
# only the CHOLMOD component changed, the UMFPACK package
# can still keep using the old suite version; there is no
# need to rebuild UMFPACK from the new suite tarball).

# @ECLASS-VARIABLE: SUITESPARSE_COMP
# @REQUIRED
# @DESCRIPTION: The component (out of the suite) that is being built.
#
# @ECLASS-VARIABLE: SUITESPARSE_DEPS
# @DESCRIPTION: The component (out of the suite) that is being built.

# @ECLASS-VARIABLE: SUITESPARSE_PARENT
# @INTERNAL
# @DESCRIPTION: Top-level directory in the suite tarball.
SUITESPARSE_PARENT="SuiteSparse-${SUITESPARSE_VER}"

# @ECLASS-VARIABLE: SUITESPARSE_COMPONENTS
# @INTERNAL
# @DESCRIPTION:
# List of components in the suite (match subdirectory names).
SUITESPARSE_COMPONENTS="
	AMD
	BTF
	CAMD
	CCOLAMD
	CHOLMOD
	COLAMD
	CXSparse
	GPUQREngine
	KLU
	LDL
	SPQR
	SuiteSparse_GPURuntime
	UMFPACK
"

EXPORT_FUNCTIONS src_unpack src_prepare src_compile src_install

HOMEPAGE="http://www.suitesparse.com \
	  http://faculty.cse.tamu.edu/davis/suitesparse.html"
SRC_URI="https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/v${SUITESPARSE_VER}.tar.gz -> suitesparse-${SUITESPARSE_VER}.tar.gz"

S="${WORKDIR}/${SUITESPARSE_PARENT}/${SUITESPARSE_COMP}"

IUSE="static-libs"

# @FUNCTION: suitesparse_src_unpack
# @USAGE:
# @DESCRIPTION: Unpack only the one component from the suite tarball.
suitesparse_src_unpack() {
	local paths=()
	for comp in ${SUITESPARSE_COMP} ${SUITESPARSE_DEPS}; do
		paths+=(${SUITESPARSE_PARENT}/${comp})
	done
	tar xf "${DISTDIR}/${A}" "${paths[@]}"

	#default
	## unpack func doesn't support unpacking only part of archive, so delete
	## everything except what we need (for meaningful dir size info)
	#find "${SUITESPARSE_PARENT}" -not \( -path "${SUITESPARSE_PARENT}" \
	#	-o -path "${SUITESPARSE_PARENT}/${SUITESPARSE_COMP}" \
	#	-o -path "${SUITESPARSE_PARENT}/${SUITESPARSE_COMP}/*" \) -delete || die
}

# @FUNCTION: suitesparse_src_prepare
# @USAGE:
# @DESCRIPTION: Point to makefile, headers installed by sci-libs/suitesparseconfig.
suitesparse_src_prepare() {
	default
	local MKD="${EPREFIX}/usr/share/suitesparseconfig"
	local INCD="${EPREFIX}/usr/include"
	local COMPS=$(echo ${SUITESPARSE_COMPONENTS} | sed 's/\s\+/\\|/g')
	find -type f -name Makefile -execdir sed -i \
		-e "s@^\s*\(include\)\s\+\S\+/SuiteSparse_config/\(SuiteSparse_config.mk\)\$@\1 ${MKD}/\2@" \
		-e "s@\S\+/\(SuiteSparse_config\|\(${COMPS}\)/Include\)/\(\S\+.h\)\(\s\+\|\$\)@${INCD}/\3 @g" \
		-e "s@-I\s*\S\+/\(SuiteSparse_config\|\(${COMPS}\)/\(Include\|Source\)\)\(\s\+\|\$\)@@g" \
		{} + || die
}

# @FUNCTION: suitesparse_src_configure
# @USAGE:
# @DESCRIPTION: Empty (no configure step in SuiteSparse build system).
suitesparse_src_configure() {
	true
}

# @FUNCTION: suitesparse_src_compile
# @USAGE: [make_arg ...]
# @DESCRIPTION:
# Compile the component (S is assumed to be set to the component's subdirectory
# in the SuiteSparse tarball) storing the artifacts in the intermeitate temporary
# destination directory (given by suitesparse_dest function). Optinally
# accepts additional make arguments (a target or variable assignment).
suitesparse_src_compile() {
	echo "ARGSG" "$1"
	# Upstream Makefile doesn't separate static/shared/doc and build/install
	# into targets well, so invoke target that builds and installs both.
	emake LDFLAGS_RPATH= \
		INSTALL_INCLUDE="${T}"/dest/usr/include \
		INSTALL_LIB="${T}"/dest/usr/$(get_libdir) \
		INSTALL_DOC="${T}"/dest/doc \
		"$@" install

	# In case dependency traking is broken: do each target in sequence
	#local TARGETS="$@ install"
	#for target in ${TARGETS}; do # parallel is broken
	#	emake LDFLAGS_RPATH= \
	#		INSTALL_INCLUDE="${T}"/dest/usr/include \
	#		INSTALL_LIB="${T}"/dest/usr/$(get_libdir) \
	#		INSTALL_DOC="${T}"/dest/doc \
	#		"${target}"
	#done
}

# @FUNCTION: suitesparse_src_install
# @USAGE:
# @DESCRIPTION:
# Install the component from the intermediate temporary destination directory
# (given by suitesparse_dest function) into the package image directory.
suitesparse_src_install() {
	if use static-libs; then
		into /usr
		dolib.a ${LIB_DIR:-Lib}/lib${PN}.a
	fi

	insinto /
	doins -r "${T}"/dest/usr
	dodoc -r "${T}"/dest/doc
}
