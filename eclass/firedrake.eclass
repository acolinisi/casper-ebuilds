# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: firedrake.eclass
# @MAINTAINER:
# Alexei Colin <ac@alexeicolin.com>
# @BLURB: Install a forked dependency of Firedrake into a sub dir of a slot

# @ECLASS-VARIABLE: FIREDRAKE_SLOT_SUBDIR
# @INTERNAL
# @DESCRIPTION: Subdirectory within Python site directory
FIREDRAKE_SLOT_SUBDIR="firedrake_suite"

# @FUNCTION: firedrake_slot_subdir
# @USAGE:
# @DESCRIPTION:
# Returns the subdirectory of site directory where modules will be moved to.
firedrake_slot_subdir()
{
	echo "${FIREDRAKE_SLOT_SUBDIR}"
}

# @FUNCTION: firedrake_src_unpack
# @USAGE:
# @DESCRIPTION:
# Move the installed python module into a subdirectory in the Python site
# directory. Call this function last in install phase (e.g. python_install_all).
firedrake_install()
{
	# To support side-by-side slot with "mainline" versions (aka. FEniCS)
	local sitedir="${D}/$(python_get_sitedir)"
	local subdir="${FIREDRAKE_SLOT_SUBDIR}"
	mkdir -p "${sitedir}_${subdir}"
	mv ${sitedir}/* "${sitedir}_${subdir}/"
	mv "${sitedir}_${subdir}" "${sitedir}/${subdir}"
}
