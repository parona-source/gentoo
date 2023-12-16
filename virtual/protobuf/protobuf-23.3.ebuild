# Copyright 2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ABSEIL_VER="20230125"

inherit multilib-build

DESCRIPTION="Virtual for protobuf"

LICENSE=""
SLOT="0/${PV}.${ABSEIL_VER}"

KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~loong ~mips ~ppc64 ~riscv ~x86 ~amd64-linux ~x86-linux ~x64-macos"

RDEPEND="
	dev-cpp/abseil-cpp:0/${ABSEIL_VER}[${MULTILIB_USEDEP}]
	dev-libs/protobuf:0/${PV}.0[${MULTILIB_USEDEP}]
"
