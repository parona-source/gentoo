# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: java-any.eclass
# @MAINTAINER:
# Alfred Wingate <parona@protonmail.com>
# @AUTHOR:
# Alfred Wingate <parona@protonmail.com>
# @SUPPORTED_EAPIS: 8
# @BLURB:
# @DESCRIPTION:

case ${EAPI} in
	8) ;;
	*) die "${ECLASS}: EAPI ${EAPI:-0} not supported" ;;
esac

if [[ ! ${_JAVA_ANY_ECLASS} ]]; then
_JAVA_ANY_ECLASS=1

declare -a -g -r _JAVA_SLOTS_ORDERED=(
	"25"
	"21"
	"17"
	"11"
	"8"
)

# == user control knobs ==

# @ECLASS_VARIABLE: EJAVA_VM_OVERRIDE
# @USER_VARIABLE
# @DESCRIPTION:
# Specify the Java VM to be used by the package. This is
# useful for troubleshooting and debugging purposes. If unset, the newest
# acceptable Java version will be used.
# This variable must not be set in ebuilds.

# == control variables ==

# @ECLASS_VARIABLE: JAVA_MAX_VER
# @PRE_INHERIT
# @DEFAULT_UNSET
# @DESCRIPTION:
# Highest Java slot supported by the package. Needs to be set before
# java_pkg_setup is called. If unset, no upper bound is assumed.

# @ECLASS_VARIABLE: JAVA_MIN_VER
# @PRE_INHERIT
# @DEFAULT_UNSET
# @DESCRIPTION:
# Lowest Java slot supported by the package. Needs to be set before
# java_pkg_setup is called. If unset, no lower bound is assumed.

# @ECLASS_VARIABLE: JAVA_VM
# @OUTPUT_VARIABLE
# @DESCRIPTION:
# The selected Java VM for building, from the range defined by
# JAVA_MAX_VER and JAVA_MIN_VER. This is set by java_pkg_setup.

# @ECLASS_VARIABLE: JAVA_NEEDS_JDK
# @PRE_INHERIT
# @DEFAULT_UNSET
# @DESCRIPTION:
#

# == global metadata ==

_java_set_globals() {
	debug-print-function ${FUNCNAME} "$@"

	# If RUST_MIN_VER is older than our oldest slot we'll just set it to that
	# internally so we don't have to worry about it later.
	if ver_test "${_JAVA_SLOTS_ORDERED[-1]}" -gt "${JAVA_MIN_VER:-0}"; then
		JAVA_MIN_VER="${_JAVA_SLOTS_ORDERED[-1]}"
	fi

	# and if it falls between slots we'll set it to the next highest slot
	# We can skip this we match a slot exactly.
	if [[ "${_JAVA_SLOTS_ORDERED[@]}" != *"${JAVA_MIN_VER}"* ]]; then
		local i
		for (( i=${#_JAVA_SLOTS_ORDERED[@]}-1 ; i>=0 ; i-- )); do
			if ver_test "${_JAVA_SLOTS_ORDERED[$i]}" -gt "${JAVA_MIN_VER}"; then
				JAVA_MIN_VER="${_JAVA_SLOTS_ORDERED[$i]}"
				break
			fi
		done
	fi

	if [[ -n "${JAVA_MAX_VER}" && -n "${JAVA_MIN_VER}" ]]; then
		if ! ver_test "${JAVA_MAX_VER}" -ge "${JAVA_MIN_VER}"; then
			die "JAVA_MAX_VER must not be older than JAVA_MIN_VER"
		fi
	fi

	local slot
	# Try to keep this in order of newest to oldest
	for slot in "${_JAVA_SLOTS_ORDERED[@]}"; do
		if ver_test "${slot}" -le "${JAVA_MAX_VER:-9999}" &&
			ver_test "${slot}" -ge "${JAVA_MIN_VER:-0}"
			then
				_JAVA_SLOTS+=( "${slot}" )
		fi
	done

	_JAVA_SLOTS=( "${_JAVA_SLOTS[@]}" )
	readonly _JAVA_SLOTS

	local java_dep=()
	java_dep=( "|| (" )
	# We can be more flexible if we generate a simpler, open-ended dependency
	# when we don't have a max version set.
	if [[ -z "${JAVA_MAX_VER}" ]]; then
		[[ -z "${JAVA_NEEDS_JDK}" ]] && java_dep+=( ">=dev-java/openjdk-jre-bin-${JAVA_MIN_VER}:*" )
   		java_dep+=(
			">=dev-java/openjdk-bin-${JAV_MIN_VER}:*"
		  	">=dev-java/openjdk-${JAVA_MIN_VER}:*"
	  	)
	else
		# depend on each slot between JAVA_MIN_VER and JAVA_MAX_VER; it's a bit specific but
	   	# won't hurt as we only ever add newer Java slots.
		for slot in "${_JAVA_SLOTS[@]}"; do
			[[ -z "${JAVA_NEEDS_JDK}" ]] && java_dep+=( "dev-java/openjdk-jre-bin:${slot}" )
			java_dep+=(
				"dev-java/openjdk-bin:${slot}"
				"dev-java/openjdk:${slot}"
			)
		done
	fi
	java_dep+=( ")" )
	JAVA_DEPEND="${java_dep[*]}"

	readonly JAVA_DEPEND
	if [[ -z ${JAVA_OPTIONAL} ]]; then
		BDEPEND="${JAVA_DEPEND}"
	fi
}
_java_set_globals
unset -f _java_set_globals

# == ebuild helpers ==

# @FUNCTION: _get_rust_slot
# @USAGE: [-b|-d]
# @DESCRIPTION:
# Find the newest Rust install that is acceptable for the package,
# and export its version (i.e. SLOT) and type (source or bin[ary])
# as RUST_SLOT and RUST_TYPE.
#
# If -b is specified, the checks are performed relative to BROOT,
# and BROOT-path is returned. -b is the default.
#
# If -d is specified, the checks are performed relative to ESYSROOT,
# and ESYSROOT-path is returned.
#
# If RUST_M{AX,IN}_VER is non-zero, then only Rust versions that
# are not newer or older than the specified slot(s) will be considered.
# Otherwise, all Rust versions are considered acceptable.
#
# If the `rust_check_deps()` function is defined within the ebuild, it
# will be called to verify whether a particular slot is acceptable.
# Within the function scope, RUST_SLOT and LLVM_SLOT will be defined.
#
# The function should return a true status if the slot is acceptable,
# false otherwise. If rust_check_deps() is not defined, the function
# defaults to checking whether a suitable Rust package is installed.
_get_java_slot() {
	debug-print-function ${FUNCNAME} "$@"

	local hv_switch=-b
	while [[ ${1} == -* ]]; do
		case ${1} in
			-b|-d) hv_switch="${1}";;
			*) break;;
		esac
		shift
	done

	local max_slot
	if [[ -z "${JAVA_MAX_VER}" ]]; then
		max_slot=
	else
		max_slot="${JAVA_MAX_VER}"
	fi
	local slot

	# iterate over known slots, newest first
	for slot in "${_JAVA_SLOTS_ORDERED[@]}"; do
		# skip higher slots
		if [[ -n "${max_slot}" ]]; then
			if ver_test "${slot}" -eq "${max_slot}"; then
				max_slot=
			elif ver_test "${slot}" -gt "${max_slot}"; then
				continue
			fi
		fi

		if [[ -n "${EJAVA_SLOT_OVERRIDE}" && "${slot}" != "${EJAVA_SLOT_OVERRIDE}" ]]; then
			continue
		fi

		einfo "Checking whether Java ${slot} is suitable ..."

		if declare -f java_check_deps >/dev/null; then
			local JAVA_SLOT="${slot}"
			java_check_deps && return
		else
			# When checking for installed packages prefer the source package;
			# if effort was put into building it we should use it.
			local java_pkgs
			case "${JAVA_TYPE_OVERRIDE}" in
				openjdk)
					java_pkgs=(
						"dev-java/openjdk:${slot}"
					)
					;;
				openjdk-bin)
					java_pkgs=(
						"dev-java/openjdk-bin:${slot}"
					)
					;;
				openjdk-jre-bin)
					java_pkgs=(
						"dev-java/openjdk-jre-bin:${slot}"
					)
					;;
				*)
					java_pkgs=(
						"dev-java/openjdk:${slot}"
						"dev-java/openjdk-bin:${slot}"
						"dev-java/openjdk-jre-bin:${slot}"
					)
					;;
			esac
			local _pkg
			for _pkg in "${java_pkgs[@]}"; do
				einfo " Checking for ${_pkg} ..."
				if has_version "${hv_switch}" "${_pkg}"; then
					case "${_pkg}" in
						dev-java/openjdk:${slot})
							export JAVA_VM="openjdk-${slot}"
							;;
						dev-java/openjdk-bin:${slot})
							export JAVA_VM="openjdk-bin-${slot}"
							;;
						dev-java/openjdk-jre-bin:${slot})
							export JAVA_VM="openjdk-jre-bin-${slot}"
							;;
					esac
					return
				fi
			done
		fi

		# We want to process the slot before escaping the loop if we've hit the minimum slot
		if ver_test "${slot}" -eq "${JAVA_MIN_VER}"; then
			break
		fi
	done

	# max_slot should have been unset in the iteration
	if [[ -n "${max_slot}" ]]; then
		die "${FUNCNAME}: invalid max_slot=${max_slot}"
	fi

	local requirement_msg=""
	[[ -n "${JAVA_MAX_VER}" ]] && requirement_msg+="<= ${JAVA_MAX_VER} "
	[[ -n "${JAVA_MIN_VER}" ]] && requirement_msg+=">= ${JAVA_MIN_VER} "
	requirement_msg="${requirement_msg% }"
	die "No Java matching requirements${requirement_msg:+ (${requirement_msg})} found installed!"
}

java-any_pkg_setup() {
	debug-print-function ${FUNCNAME} "$@"

	if [[ ${MERGE_TYPE} != binary ]]; then
		_get_java_slot
		einfo "Using Java ${JAVA_VM}"

		export JAVA=$(java-config --select-vm=${JAVA_VM} --java)
		export JAVAC=$(java-config --select-vm=${JAVA_VM} --javac)
		export JAVA_HOME="$(java-config --select-vm=${JAVA_VM} -g JAVA_HOME)"
		export JDK_HOME=${JAVA_HOME}
	fi
}

fi

EXPORT_FUNCTIONS pkg_setup
