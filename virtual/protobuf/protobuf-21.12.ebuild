# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit multilib-build

DESCRIPTION="Virtual for protobuf"

LICENSE=""
SLOT="0/${PV}"

KEYWORDS="~alpha amd64 arm arm64 ~loong ~mips ppc64 ~riscv x86 ~amd64-linux ~x86-linux ~x64-macos"

RDEPEND="
	dev-libs/protobuf:0/3.${PV}.0[${MULTILIB_USEDEP}]
"
