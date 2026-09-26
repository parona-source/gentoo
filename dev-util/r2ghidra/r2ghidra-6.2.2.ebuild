# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson flag-o-matic

DESCRIPTION="Native Ghidra Decompiler for r2"
HOMEPAGE="https://www.radare.org https://github.com/radareorg/r2ghidra"
SRC_URI="https://github.com/radareorg/r2ghidra/releases/download/${PV}/${P}.tar.xz"

# https://github.com/radareorg/r2ghidra/blob/master/LICENSE.md
LICENSE="LGPL-3"
# ghidra
LICENSE+=" Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
	>=dev-util/radare2-6.1.4:=
	>=virtual/zlib-1.2.8:=
"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

src_configure() {
	# ODR violations in ghidra
	filter-lto

	meson_src_configure
}
