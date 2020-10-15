# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_8 )
DISTUTILS_SINGLE_IMPL=1

inherit distutils-r1 firedrake

DESCRIPTION="Automated system for the portable solution of partial differential equations using the finite element method (FEM)"
HOMEPAGE="https://github.com/firedrakeproject/firedrake"
SRC_URI="https://github.com/firedrakeproject/${PN}/archive/Firedrake_${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL"
SLOT="0"
KEYWORDS="amd64 ~amd64-linux"
# index-64bit flag in order to keep our configuration.json in sync with petsc installation
IUSE="test examples complex-scalars index-64bit mpi metis scotch slepc"

# NOTE: when neither ptscotch, nor parmetis is available in PETSc (as
# specified in firedrake's configuration.json), and PETSc is built for 32-bit
# ints, firedrake falls back to Chaco, which is not packaged for Gentoo, and
# it's not worth since it's not great, so just require ptscotch or parmetis.
REQUIRED_USE="${PYTHON_REQUIRED_USE}
	mpi? ( metis scotch )
	"

MY_FV=$(ver_cut 1)

S="${WORKDIR}/${PN}-Firedrake_${PV}"

BDEPEND="
	test?  ( $(python_gen_cond_dep '
		dev-python/pytest[${PYTHON_MULTI_USEDEP}]
		dev-python/pytest-xdist[${PYTHON_MULTI_USEDEP}]
		dev-python/pylint[${PYTHON_MULTI_USEDEP}]
		') )
	"
# NOTE: libspatialindex needs a patch that fixes C API
DEPEND="
	>=sci-libs/libsupermesh-1.0.1.20190401
	>=sci-libs/libspatialindex-1.8.5-r1
	sci-mathematics/petsc[hdf5,eigen,scotch?,metis?,complex-scalars=,index-64bit=]
	slepc? ( sci-mathematics/slepc[complex-scalars=,index-64bit=] )
	"
RDEPEND="
	=dev-python/fiat-${MY_FV}*:fd[${PYTHON_SINGLE_USEDEP}]
	=dev-python/finat-${MY_FV}*:fd[${PYTHON_SINGLE_USEDEP}]
	=dev-python/tsfc-${MY_FV}*:fd[${PYTHON_SINGLE_USEDEP}]
	=dev-python/pyop2-${MY_FV}*:fd[${PYTHON_SINGLE_USEDEP}]
	=dev-python/ufl-${MY_FV}*:fd[${PYTHON_SINGLE_USEDEP}]

 	$(python_gen_cond_dep '
	dev-python/pyadjoint[${PYTHON_MULTI_USEDEP}]
	dev-python/cachetools[${PYTHON_MULTI_USEDEP}]
	dev-python/h5py[${PYTHON_MULTI_USEDEP}]
	dev-python/matplotlib[${PYTHON_MULTI_USEDEP}]
	dev-python/sympy[${PYTHON_MULTI_USEDEP}]
	>=dev-python/randomgen-1.16.4[${PYTHON_MULTI_USEDEP}]
	<dev-python/randomgen-1.18[${PYTHON_MULTI_USEDEP}]
	')
	sci-libs/vtk[python]
	"

PATCHES=(
	"${FILESDIR}/${P}-vtk-8.2.patch"
	"${FILESDIR}/${P}-mesh-partitioner-config.patch"
	"${FILESDIR}/${P}-no-venv.patch"
	"${FILESDIR}/${P}-no-hdf5.patch"
	"${FILESDIR}/${P}-sniff-compiler.patch"
	"${FILESDIR}/${P}-CCVER-var.patch"
	)
#"${FILESDIR}/${P}-slot-pypath.patch"

python_prepare() {
	# Point Python path to the slotted dependencies
	local py_path_code=(
	'# EBUILD: choose the forked rather than "mainline" (aka. FEniCS) dep versions'
	"sys.path.insert(0, os.path.join(os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir)), \"$(firedrake_slot_subdir)\"))"
	)

	local prev_line='import\s*sys\s*'
	for line in "${py_path_code[@]}"; do
		sed -i "/^${prev_line}\$/a ${line}" ${PN}/__init__.py
		prev_line="${line}"
	done
}

python_compile() {
	distutils-r1_python_compile
	use examples && emake -C demos
}

python_install_all()
{
	distutils-r1_python_install_all

	# Create config generate by the upstream install-firedrake script
	cat <<-EOF > configuration.json
	{
	  "options": {
	    "package_manager": false,
	    "minimal_petsc": false,
	    "mpicc": "${EPREFIX}/usr/bin/mpicc",
	    "mpicxx": "${EPREFIX}/usr/bin/mpicxx",
	    "mpif90": "${EPREFIX}/usr/bin/mpif90",
	    "mpiexec": "${EPREFIX}/usr/bin/mpiexec",
	    "disable_ssh": true,
	    "honour_petsc_dir": true,
	    "with_ptscotch": $(usex scotch true false),
	    "with_parmetis": $(usex metis true false),
	    "with_chaco": false,
	    "slepc": $(usex slepc true false),
	    "packages": [],
	    "honour_pythonpath": true,
	    "opencascade": false,
	    "petsc_int_type": "$(usex index-64bit int64 int32)",
	    "cache_dir": "${EPREFIX}/var/cache"
	  },
	  "environment": {},
	  "additions": []
	}
	EOF

	#local pyver=$(python --version | sed 's/Python \(\d\.\d\)\.\d/\1/')
	#local pyver=$(ver_cut 1-2 $(python --version | sed 's/Python\s*//'))
	#insinto /usr/lib/python${pyver}/site-packages/firedrake_configuration
	local sitedir=$(python_get_sitedir)
	insinto ${sitedir#${EPREFIX}}/firedrake_configuration
	doins configuration.json

	## Point Python path to the slotted dependencies
	#read PY_PATH_CODE <<-EOF
	## Choose the forked rather than "mainline" (aka. FEniCS) dep versions
	#sys.path.append(os.path.join(os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir)), '${FIREDRAKE_DEP_SLOT_DIR}'))
	#EOF

	#sed -i "/^import\s*sys\$/a ${PY_PATH_CODE}/" ${ED}/$(python_get_sitedir)/${PN}/__init__.py

	insinto /usr/share/${PN}
	use examples && doins -r demos
}
