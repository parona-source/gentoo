# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: bazel.eclass
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

if [[ ! ${_BAZEL_ECLASS} ]]; then
_BAZEL_ECLASS=1

inherit multiprocessing toolchain-funcs

if [[ "${PN}" != bazel ]]; then
	BDEPEND="|| ( dev-build/bazel-bin dev-build/bazel )"
fi

EBAZEL_HOME="${WORKDIR}/bazel_home"
EBAZELRC="${EBAZEL_HOME}/bazelrc"
EBAZEL_VENDOR="${EBAZEL_HOME}/vendor"

# @ECLASS_VARIABLE: EBAZEL_HOME
# @OUTPUT_VARIABLE
# @DESCRIPTION:
# Location of the bazel home directory.

# https://bazel.build/run/bazelrc
# @ECLASS_VARIABLE: EBAZELRC
# @OUTPUT_VARIABLE
# @DESCRIPTION:
# Generated bazelrc file to be used by bazel.

# https://bazel.build/external/vendor
# @ECLASS_VARIABLE: EBAZEL_VENDOR
# @OUTPUT_VARIABLE
# @DESCRIPTION:
# Location of the bazel vendor directory.
#
# bazel vendor --vendor_dir=bazel_home/vendor <targets>
# XZ_OPT='-T0 -9' tar caf ${P}-vendor.tar.xz bazel_home
#
# Note: You need all possible targets for the ebuild in the command line.
# To avoid downloading hermetic toolchains make sure to enable options for the local toolchain.

# @ECLASS_VARIABLE: BAZEL
# @DEFAULT_UNSET
# @OUTPUT_VARIABLE
# @DESCRIPTION:
# Set path of a suitable "bazel" executable.
#
# This variable is set automatically by "bazel_pkg_setup" function.

# https://bazel.build/docs/user-manual
# https://bazel.build/reference/be/make-variables
# https://bazel.build/docs/cc-toolchain-config-reference

# @ECLASS_VARIABLE: BAZEL_BUILD_ARGS
# @DEFAULT_UNSET
# @DESCRIPTION:
#

# @ECLASS_VARIABLE: BAZEL_BUILD_TARGETS
# @DEFAULT_UNSET
# @DESCRIPTION:
#

# @ECLASS_VARIABLE: BAZEL_TEST_TARGETS
# @DEFAULT_UNSET
# @DESCRIPTION:
#

# https://bazel.build/docs/user-manual#running-tests
# @ECLASS_VARIABLE: BAZEL_TEST_ARGS
# @DEFAULT_UNSET
# @DESCRIPTION:
#

# @FUNCTION: bazel_pkg_setup
# @DESCRIPTION:
#
bazel_pkg_setup() {
	BAZEL="bazel-bin-${BAZEL_COMPAT}"
}

# @FUNCTION: bazel_live_src_unpack
# @DESCRIPTION:
# Run 'bazel vendor' and fetched all the required sources for the targets for offline use, used in live ebuilds.
bazel_live_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	[[ "${PV}" == *9999* ]] || die "${FUNCNAME} only allowed in live/9999 ebuilds"
	[[ "${EBUILD_PHASE}" == unpack ]] || die "${FUNCNAME} only allowed in src_unpack"

	if [[ -z ${BAZEL_VENDOR_TARGETS} ]] ; then
		BAZEL_VENDOR_TARGETS=( ${BAZEL_BUILD_TARGETS[@]} ${BAZEL_TEST_TARGETS[@]} )
	fi

	set -- bazel vendor --vendor_dir="${EBAZEL_VENDOR}" "${BAZEL_VENDOR_TARGETS[@]}"
	einfo "$@"
	"$@" || die "bazel vendor failed"
}

# @FUNCTION: bazel_gen_bazelrc
# @DESCRIPTION:
# Generate ${EBAZEL_HOME}/bazelrc with options that will be used for every invocation of bazel.
bazel_gen_bazelrc() {
	debug-print-function ${FUNCNAME} "$@"

	get_flags() {
		local opt="${1}"
		shift
		local -a _FLAGS=( ${@} )
		if [[ ${#_FLAGS[*]} -gt 0 ]]; then
			echo "common ${_FLAGS[*]/#/${opt}=}"
		else
			echo "#"
		fi
	}

	mkdir -p "${EBAZEL_HOME}"
	cat > "${EBAZELRC}" <<- _EOF_ || die "Failed to create bazelrc"
	startup --batch
	startup --output_base=${T}/bazel_output/
	$([[ "${NOCOLOR}" = true || "${NOCOLOR}" = yes ]] && echo "startup --color=no")

	# Easier debugging from build.log
	common --announce_rc

	# Sanboxing not relevant as ebuilds are executed in a sandbox
	common --spawn_strategy="local"

	common --jobs="$(get_makeopts_jobs)"
	common --compilation_mode=opt --host_compilation_mode=opt
	common --strip="never"

	common --subcommands --verbose_failures --noshow_loading_progress --noshow_progress
	test --test_summary=detailed --test_output=all --verbose_test_summary

	common --repository_disable_download
	common --vendor_dir="${EBAZEL_VENDOR}"

	# Java configuration
	# https://bazel.build/docs/bazel-and-java
	common --java_runtime_version=local_jdk
	common --tool_java_runtime_version=local_jdk
	#common --extra_toolchains=@local_jdk//:all

	# C/C++ configuration
	# https://bazel.build/docs/cc-toolchain-config-reference
	common --compiler=$(tc-getCC)
	# CFLAGS
	$(get_flags --conlyopt ${CFLAGS})
	$(get_flags --host_conlyopt ${BUILD_CFLAGS})
	# CXXFLAGS
	$(get_flags --cxxopt ${CXXFLAGS})
	$(get_flags --host_cxxopt ${BUILD_CXXFLAGS})
	# CPPFLAGS
	$(get_flags --conlyopt ${CPPFLAGS})
	$(get_flags --cxxopt ${CPPFLAGS})
	$(get_flags --host_conlyopt ${BUILD_CPPFLAGS})
	$(get_flags --host_cxxopt ${BUILD_CPPFLAGS})
	# LDFLAGS
	$(get_flags --linkopt ${LDFLAGS})
	$(get_flags --host_linkopt ${BYILD_LDFLAGS})

	# Python configuration
	# https://github.com/bazel-contrib/rules_python/issues/2070
	common --extra_toolchains=@rules_python//python/runtime_env_toolchains:all
	_EOF_

	# TODO: Figure out a way to automagically include toolchain options where relevant
}

# @FUNCTION: bazel_src_configure
# @DESCRIPTION:
bazel_src_configure() {
	debug-print-function ${FUNCNAME} "$@"

	# F: fopen_wr
	# P: /proc/self/setgroups
	# Even with standalone enabled, the Bazel sandbox binary is run for feature test:
	# https://github.com/bazelbuild/bazel/blob/7b091c1397a82258e26ab5336df6c8dae1d97384/src/main/java/com/google/devtools/build/lib/sandbox/LinuxSandboxedSpawnRunner.java#L61
	# https://github.com/bazelbuild/bazel/blob/76555482873ffcf1d32fb40106f89231b37f850a/src/main/tools/linux-sandbox-pid1.cc#L113
	addpredict /proc

	tc-export AR NM OBJCOPY STRIP

	bazel_gen_bazelrc

	einfo "Configured targets: ${BAZEL_BUILD_TARGETS[@]}"
}

# @FUNCTION: ebazel
# @DESCRIPTION:
ebazel() {
	debug-print-function ${FUNCNAME} "$@"

	set -- "${BAZEL}" --bazelrc="${EBAZELRC}" "${@}"
	einfo "$@"
	"$@" || die "bazel ${1} failed"
}

# @FUNCTION: bazel_src_compile
# @DESCRIPTION:
bazel_src_compile() {
	debug-print-function ${FUNCNAME} "$@"

	ebazel build "${BAZEL_BUILD_ARGS[@]}" "${BAZEL_BUILD_TARGETS[@]}"
}

# @FUNCTION: bazel_src_test
# @DESCRIPTION:
bazel_src_test() {
	debug-print-function ${FUNCNAME} "$@"

	[[ -z ${BAZEL_TEST_TARGETS} ]] && return 0

	local test_targets=( $(ebazel query "tests(set(${BAZEL_TEST_TARGETS[@]})) ${BAZEL_SKIP_TESTS[@]/#/except }") )

	ebazel test --build_tests_only "${BAZEL_BUILD_ARGS[@]}" "${BAZEL_TEST_ARGS[@]}" "${test_targets[@]}"
}

fi

EXPORT_FUNCTIONS src_configure src_compile src_test
