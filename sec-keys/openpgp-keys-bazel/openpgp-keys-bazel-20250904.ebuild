# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

SEC_KEYS_VALIDPGPKEYS=(
	"71A1D0EFCFEB6281FD0437C93D5919B448457EE0:bazel:manual"
)

inherit sec-keys

DESCRIPTION="OpenPGP key used to sign Bazel releases"
HOMEPAGE="https://bazel.build/"
SRC_URI+="https://bazel.build/bazel-release.pub.gpg -> ${P}-bazel-release.pub.gpg"

KEYWORDS="~amd64"
