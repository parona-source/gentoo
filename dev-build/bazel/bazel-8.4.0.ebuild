# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BAZEL_COMPAT=8

JAVA_VERSION=21

_JAVA_PKG_WANT_BUILD_VM=( {openjdk{,-jre},icedtea}{,-bin}-${JAVA_VERSION} )
JAVA_PKG_WANT_BUILD_VM=${_JAVA_PKG_WANT_BUILD_VM[@]}
# Required to be set, but not used.
JAVA_PKG_WANT_SOURCE=${JAVA_VERSION}
JAVA_PKG_WANT_TARGET=${JAVA_VERSION}

PYTHON_COMPAT=( python3_{11..14} )
inherit bazel check-reqs flag-o-matic java-pkg-2 multiprocessing python-any-r1 shell-completion verify-sig

DESCRIPTION="A fast, scalable, multi-language and extensible build system"
HOMEPAGE="https://bazel.build/"
SRC_URI="
	https://github.com/bazelbuild/bazel/archive/refs/tags/${PV}.tar.gz
		-> ${P}.tar.gz
	${P}-vendor.tar.xz
	!system-bootstrap? (
		https://github.com/bazelbuild/bazel/releases/download/${PV}/bazel-${PV}-dist.zip
		verify-sig? (
			https://github.com/bazelbuild/bazel/releases/download/${PV}/bazel-${PV}-dist.zip.sig
		)
	)
"

LICENSE="Apache-2.0"
SLOT="$(ver_cut 1)"
KEYWORDS="~amd64"

# lld or mold only linkers that work
# gcc causes build failure for tests

IUSE="+force-lld system-bootstrap"

# Stripping will break bazel because its a zip file in disguise
RESTRICT="strip"

RDEPEND="
	virtual/jdk:${JAVA_VERSION}
"
BDEPEND="
	${PYTHON_DEPS}
	app-arch/unzip
	app-arch/zip
	virtual/jdk:${JAVA_VERSION}
	force-lld? (
		llvm-core/lld
	)
	system-bootstrap? (
		|| (
			dev-build/bazel:${BAZEL_COMPAT}
			dev-build/bazel-bin:${BAZEL_COMPAT}
		)
	)
	verify-sig? (
		sec-keys/openpgp-keys-bazel
	)
"

VERIFY_SIG_OPENPGP_KEY_PATH=/usr/share/openpgp-keys/bazel.asc

BAZEL_TEST_TARGETS=(
	//src/test/cpp:all_tests
	//src/test/cpp/util:all_tests
	//src/test/res:all_tests
	# pulls in android deps
	#//src/test/shell/bazel:all_tests
	# requires network despite the tags + will pull embedded jdk version of bazel
	#//src/test/shell/integration:all_tests
)
BAZEL_TEST_ARGS=(
	# Over 80G build dir if test size not filtered + plenty timeouts
	--test_size_filters=small,medium
	--test_tag_filters=-flaky,-requires-network
)

BOOTSTRAP_DIR="${WORKDIR}/bazel-bootstrap"

PATCHES=(
	"${FILESDIR}"/bazel-8.4.0-completions-nojdk.patch
)

pkg_pretend() {
	CHECKREQS_DISK_BUILD="2G"
	if has test ${FEATURES} ; then
		CHECKREQS_DISK_BUILD="20G"
	fi

	check-reqs_pkg_setup
}

pkg_setup() {
	CHECKREQS_DISK_BUILD="2G"
	if has test ${FEATURES} ; then
		CHECKREQS_DISK_BUILD="20G"
	fi

	check-reqs_pkg_setup
	java-pkg-2_pkg_setup
	python-any-r1_pkg_setup
	use system-bootstrap && bazel_pkg_setup
}

src_unpack() {
	unpack "${P}.tar.gz"
	unpack "${P}-vendor.tar.xz"

	if ! use system-bootstrap; then
		verify-sig_verify_detached "${DISTDIR}"/bazel-${PV}-dist.zip{,.sig}
		mkdir "${BOOTSTRAP_DIR}"
		pushd "${BOOTSTRAP_DIR}" > /dev/null || die
		unpack "bazel-${PV}-dist.zip"
		popd >/dev/null || die
	fi
}

src_prepare() {
	# https://bugs.gentoo.org/780585
	[[ ${#PATCHES[@]} -gt 0 ]] && eapply -- "${PATCHES[@]}"
	java-pkg-2_src_prepare
}

src_configure() {
	# Force user linker
	# https://github.com/bazelbuild/rules_cc/blob/0.2.3/cc/private/toolchain/unix_cc_configure.bzl#L476
	# Linker needs to support --start-lib and --end-lib. bfd notably doesn't support it and gold doesnt exist anymore

	if use force-lld; then
		append-flags -fuse-ld=lld
	else
		if test-flags-CCLD -Wl,--start-lib -Wl,--end-lib ; then
			die "With default-lld disabled you must configure a linker that supports --start-lib and --end-lib. (lld or mold)"
		fi
	fi

	# Broken
	filter-lto

	strip-unsupported-flags

	BAZEL_BUILD_TARGETS=( //src:bazel_nojdk //scripts:bash_completion //scripts:fish_completion )
	BAZEL_BUILD_ARGS=( --stamp --embed_label="${PV}" --extra_toolchains=@local_jdk//:all )
	bazel_src_configure
}

src_compile() {
	if ! use system-bootstrap; then
		pushd "${BOOTSTRAP_DIR}" > /dev/null || die
		# Setup selfhosted bazel. This will build bazel once but with less control.
		local _bazelargs=(
			--jobs="$(get_makeopts_jobs)"
			# portage is already sandboxed
			--spawn_strategy="local"
			--strip="never"
			--subcommands
			--tool_java_runtime_version=local_jdk
			--verbose_failures
		)
		local -x EXTRA_BAZEL_ARGS="${_bazelargs[@]}"
		bash ./compile.sh || die
		export BAZEL="${BOOTSTRAP_DIR}/output/bazel"
		popd >/dev/null || die
	fi

	bazel_src_compile

	sed -e "s|: \${BAZEL:=bazel}|: \${BAZEL:=bazel-${SLOT}}|" \
		-e '/IBAZEL/d' \
		-i bazel-bin/scripts/bazel-complete.bash || die
	sed -e "s|complete -c bazel|complete -c bazel-${SLOT}|" \
		-i bazel-bin/scripts/bazel.fish || die
	sed -e "s|: \${BAZEL:=bazel}|: \${BAZEL:=bazel-${SLOT}}|" \
		-i scripts/zsh_completion/_bazel || die
}

src_install()  {
	newbin bazel-bin/src/bazel_nojdk bazel-${SLOT}

	newbashcomp bazel-bin/scripts/bazel-complete.bash bazel-${SLOT}
	newfishcomp bazel-bin/scripts/bazel.fish bazel-${SLOT}.fish
	newzshcomp scripts/zsh_completion/_bazel _bazel-${SLOT}

	einstalldocs
}
