# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

FORTRAN_NEEDED=fortran

inherit cuda flag-o-matic fortran-2 git-r3 java-pkg-opt-2 toolchain-funcs multilib multilib-minimal

EGIT_REPO_URI="https://github.com/open-mpi/ompi.git"
EGIT_SUBMODULES=( 'prrte' ) # TODO: until it's a package too

if [[ "$(ver_cut 4 ${PV})" = "pre" ]]
then
	MY_D="$(ver_cut 5 ${PV})"
	EGIT_COMMIT_DATE="${MY_D:0:4}-${MY_D:4:2}-${MY_D:6:2}"
	# TODO: will go away once prrte is separate pkg
	# TODO: doesn't work anyway.... (acknowledged, but not checked out)
	# EGIT_OVERRIDE_COMMIT_DATE_OPENPMIX_PRRTE=${EGIT_COMMIT_DATE}
	KEYWORDS="~amd64 ~amd64-linux"
else # live
	#EGIT_OVERRIDE_BRANCH_OPENPMIX_PRRTE=master
	KEYWORDS=""
fi

MY_P=${P/-mpi}
S=${WORKDIR}/${MY_P}

IUSE_OPENMPI_FABRICS="
	openmpi_fabrics_knem
	openmpi_fabrics_ofi
	openmpi_fabrics_psm
	openmpi_fabrics_ugni
	"

IUSE_OPENMPI_RM="
	openmpi_rm_alps
	openmpi_rm_pbs
	openmpi_rm_slurm"

DESCRIPTION="A high-performance message passing library (MPI)"
HOMEPAGE="http://www.open-mpi.org"
LICENSE="BSD"
SLOT="0"
# TODO: ltdl: looks for nonexistant ltprtedl.h header
IUSE="cma cray-pmi cuda debug fortran heterogeneous ipv6 java ltdl +man
	mpi1 romio internal_pmix ucx
	${IUSE_OPENMPI_FABRICS} ${IUSE_OPENMPI_RM} ${IUSE_OPENMPI_OFED_FEATURES}"

REQUIRED_USE="
	openmpi_rm_slurm? ( !openmpi_rm_pbs )
	openmpi_rm_pbs? ( !openmpi_rm_slurm )
	"

# TODO: check whether should depend on subslot of hwloc
CDEPEND="
	!sys-cluster/mpich
	!sys-cluster/mpich2
	!sys-cluster/nullmpi
	>=dev-libs/libevent-2.0.22:=[${MULTILIB_USEDEP},threads]
	ltdl? ( dev-libs/libltdl:0[${MULTILIB_USEDEP}] )
	>=sys-apps/hwloc-2.0.2[${MULTILIB_USEDEP}]
	>=sys-libs/zlib-1.2.8-r1[${MULTILIB_USEDEP}]
	cuda? ( >=dev-util/nvidia-cuda-toolkit-6.5.19-r1:= )
	openmpi_fabrics_knem? ( sys-cluster/knem )
	openmpi_fabrics_ofi? ( sys-fabric/libfabric )
	openmpi_fabrics_psm? ( sys-fabric/infinipath-psm:* )
	openmpi_fabrics_ugni? ( sys-cluster/cray-libs )
	openmpi_rm_pbs? ( sys-cluster/torque )
	openmpi_rm_alps? ( sys-cluster/cray-libs )
	cray-pmi? ( sys-cluster/cray-libs )
	internal_pmix? ( !sys-cluster/pmix )
	!internal_pmix? ( >sys-cluster/pmix-3.2.0:= )
	ucx? ( sys-cluster/ucx:= )
	"

RDEPEND="${CDEPEND}
	java? ( >=virtual/jre-1.6 )"

DEPEND="${CDEPEND}
	java? ( >=virtual/jdk-1.6 )
	man? ( app-text/pandoc )"

PATCHES=(
	"${FILESDIR}"/${PN}-5-autogen-disabled-submodules.patch
	"${FILESDIR}"/${PN}-5-autoconf-alps-cray-release.patch
	"${FILESDIR}"/${PN}-5-prrte-if-addr-match.patch
)

MULTILIB_WRAPPED_HEADERS=(
	/usr/include/mpi.h
	/usr/include/openmpi/ompi/mpi/java/mpiJava.h
)

# Be verbose when executing important commands
my_vrun() {
	echo "$@"
	"$@" || die
}

pkg_setup() {
	fortran-2_pkg_setup
	java-pkg-opt-2_pkg_setup

	elog
	elog "OpenMPI has an overwhelming count of configuration options."
	elog "Don't forget the EXTRA_ECONF environment variable can let you"
	elog "specify configure options if you find them necessary."
	elog
}

my_get_submodule_url()
{
	sed -ne "/submodule \"$1\"/,\$ p" -e '/^\s*url\s*=/q' .gitmodules \
		| sed -ne 's/^\s*url\s*=\s*\(.*\)\s*/\1/p'
}

src_prepare() {
	# Optional: update prrte submodule to latest (regardless of submodule ref)
	# TODO: this is aggressive, but it will go away once prrte is separate pkg
	#local prrte_url="$(my_get_submodule_url prrte)"
	local prrte_url="${EGIT3_STORE_DIR}/openpmix_prrte.git"
	pushd 3rd-party/prrte
	my_vrun git remote add up "${prrte_url}"
	my_vrun git fetch up
	if [[ -n "${EGIT_COMMIT}" ]]; then
		COMMIT=${EGIT_COMMIT}
	elif [[ -n "${EGIT_COMMIT_DATE}" ]]; then
		my_vrun git rev-list -1 --before ${EGIT_COMMIT_DATE} up/master
		COMMIT=$(git rev-list -1 --before ${EGIT_COMMIT_DATE} up/master)
	else
		my_vrun git rev-list -1 up/master
		COMMIT=$(git rev-list -1 up/master)
	fi
	my_vrun git fetch up "${COMMIT}" # just in case
	my_vrun git reset --hard "${COMMIT}"
	popd

	default

	# Necessary for scalibility, see
	# http://www.open-mpi.org/community/lists/users/2008/09/6514.php
	echo 'oob_tcp_listen_mode = listen_thread' \
		>> opal/etc/openmpi-mca-params.conf || die

	local submodules=(3rd-party/prrte)
	local excluded_pkgs="libevent,hwloc"
	if use internal_pmix; then
		submodules+=(3rd-party/openpmix)
	else
		excluded_pkgs+=",pmix"
	fi

	# TODO: somehow git-r3 checks out the submodules, but
	# git submodule status shows them with a '-' so check fails
	my_vrun git submodule init -- ${submodules[@]}

	if use openmpi_fabrics_ofi; then
		eapply "${FILESDIR}"/${PN}-5-odls-keep-fds-for-ofi-ugni.patch
	fi

	# Use system pkgs for all except prrte (until it's a pkg too)
	my_vrun ./autogen.pl --no-3rdparty "${excluded_pkgs}"
}

multilib_src_configure() {
	if use java; then
		# We must always build with the right -source and -target
		# flags. Passing flags to javac isn't explicitly supported here
		# but we can cheat by overriding the configure test for javac.
		export ac_cv_path_JAVAC="$(java-pkg_get-javac) $(java-pkg_javac-args)"
	fi

	# TODO: if libfabric has gni use flag, it is linked against cray
	# libs that live outside of EPREFIX, so when ./configure tests
	# linking against libfabric, linker fails; so add -rpath-link ld
	# arg. It's a libfabric ebuild problem: try fiddle with 'rpath'?
	if use openmpi_fabrics_ofi; then
		local gni_libs=(cray-ugni cray-xpmem cray-alpsutil cray-alpslli
				cray-udreg cray-wlm_detect)
		$(tc-getPKG_CONFIG) --exists ${gni_libs[@]} || die
		local gni_ldflags="$($(tc-getPKG_CONFIG) \
			--libs-only-L ${gni_libs[@]} \
			| sed 's/-L\(\S\+\)/-Wl,-rpath-link -Wl,\1/g')"
	fi

	unset F77 FFLAGS # configure warns that unused, FC, FCFLAGS is used

	echo LDFLAGS="${LDFLAGS} ${gni_ldflags}"
	LDFLAGS="${LDFLAGS} ${gni_ldflags}" \
	ECONF_SOURCE=${S} econf \
		--sysconfdir="${EPREFIX}/etc/${PN}" \
		--enable-pretty-print-stacktrace \
		--enable-prte-prefix-by-default \
		--with-hwloc="${EPREFIX}/usr" \
		--with-hwloc-libdir="${EPREFIX}/usr/$(get_libdir)" \
		--with-libevent="${EPREFIX}/usr" \
		--with-libevent-libdir="${EPREFIX}/usr/$(get_libdir)" \
		--enable-mpi-fortran=$(usex fortran all no) \
		$(use_with ltdl libltdl "${EPREFIX}/usr") \
		$(use_with cma) \
		$(multilib_native_use_with cuda cuda "${EPREFIX}"/opt/cuda) \
		$(use_enable debug) \
		$(use_enable mpi1 mpi1-compatibility) \
		$(use_enable romio io-romio) \
		$(use_enable heterogeneous) \
		$(use_enable ipv6) \
		$(use_enable man man-pages) \
		$(use_with cray-pmi) \
		$(usex internal_pmix --with-pmix="internal" --with-pmix="${EPREFIX}/usr" ) \
		$(use_with ucx ucx "${EPREFIX}/usr") \
		$(usex ucx --with-ucx-libdir="${EPREFIX}/usr/$(get_libdir)" "") \
		$(multilib_native_use_enable java mpi-java) \
		$(multilib_native_use_with openmpi_fabrics_knem knem "${EPREFIX}"/usr) \
		$(multilib_native_use_with openmpi_fabrics_ofi ofi "${EPREFIX}"/usr) \
		$(multilib_native_use_with openmpi_fabrics_psm psm2 "${EPREFIX}"/usr) \
		$(multilib_native_use_with openmpi_fabrics_ugni ugni) \
		$(multilib_native_use_with openmpi_rm_alps alps) \
		$(multilib_native_use_with openmpi_rm_pbs tm) \
		$(multilib_native_use_with openmpi_rm_slurm slurm)

	# NOTE: the openmpi_rm_* config flags are passed through to
	# the prrte submodule, the parent throws an error that they
	# are unrecognized options (harmless).
}

multilib_src_test() {
	# Doesn't work with the default src_test as the dry run (-n) fails.
	emake -j1 check
}

multilib_src_install() {
	default

	# fortran header cannot be wrapped (bug #540508), workaround part 1
	if multilib_is_native_abi && use fortran; then
		mkdir "${T}"/fortran || die
		mv "${ED}"/usr/include/mpif* "${T}"/fortran || die
	else
		# some fortran files get installed unconditionally
		rm \
			"${ED}"/usr/include/mpif* \
			"${ED}"/usr/bin/mpif* \
			|| die
	fi
}

multilib_src_install_all() {
	# fortran header cannot be wrapped (bug #540508), workaround part 2
	if use fortran; then
		mv "${T}"/fortran/mpif* "${ED}"/usr/include || die
	fi

	# Remove la files, no static libs are installed and we have pkg-config
	find "${ED}" -name '*.la' -delete || die

	if use java; then
		local mpi_jar="${ED}"/usr/$(get_libdir)/mpi.jar
		java-pkg_dojar "${mpi_jar}"
		# We don't want to install the jar file twice
		# so let's clean after ourselves.
		rm "${mpi_jar}" || die
	fi
	einstalldocs
}
