# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit java-pkg-2 verify-sig

DESCRIPTION="A fast, scalable, multi-language and extensible build system"
HOMEPAGE="https://bazel.build/"
SRC_URI="
	amd64? (
		https://github.com/bazelbuild/bazel/releases/download/${PV}/bazel_nojdk-${PV}-linux-x86_64
		verify-sig? ( https://github.com/bazelbuild/bazel/releases/download/${PV}/bazel_nojdk-${PV}-linux-x86_64.sig )
	)
	arm64? (
		https://github.com/bazelbuild/bazel/releases/download/${PV}/bazel_nojdk-${PV}-linux-arm64
		verify-sig? ( https://github.com/bazelbuild/bazel/releases/download/${PV}/bazel_nojdk-${PV}-linux-arm64.sig )
	)
"
S="${WORKDIR}"

LICENSE="Apache-2.0"
SLOT="$(ver_cut 1)"
KEYWORDS="~amd64"

RESTRICT="strip"

RDEPEND="
	sys-devel/gcc
	sys-libs/glibc
	|| (
		dev-java/openjdk-bin:21
		dev-java/openjdk:21
	)
"

VERIFY_SIG_OPENPGP_KEY_PATH=/usr/share/openpgp-keys/bazel.asc

QA_PREBUILT="*"

src_unpack() {
	local arch
	case ${ARCH} in
		amd64)
			arch="x86_64"
			;;
		arm64)
			arch="arm64"
			;;
		*)
			die "Unsupported arch ${ARCH}"
	esac

	verify-sig_verify_detached "${DISTDIR}"/bazel_nojdk-${PV}-linux-${arch}{,.sig}
	cp "${DISTDIR}"/bazel_nojdk-${PV}-linux-${arch} "${WORKDIR}"/bazel_nojdk-${PV} || die
}

src_install() {
	insinto /opt/bazel-bin-${SLOT}

	exeinto /opt/bazel-bin-${SLOT}
	doexe "${WORKDIR}"/bazel_nojdk-${PV}

	# TODO cludge
	newbin - bazel-bin-${SLOT} <<- EOF
	#!/usr/bin/env bash
	source ${EPRFIX}//usr/share/java-config-2/vm/openjdk-bin-21
	/opt/bazel-bin-${SLOT}/bazel_nojdk-${PV} ${@}
	EOF
}
