# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LIBRETRO_REPO_NAME="libretro/snes9x"

inherit libretro-core

DESCRIPTION="Snes9x libretro port"
S="${S}/libretro"
LIBRETRO_CORE_LIB_FILE="${S}/${LIBRETRO_CORE_NAME}_libretro.so"
LICENSE="Snes9x GPL-2 GPL-2+ LGPL-2.1 LGPL-2.1+ ISC MIT ZLIB Info-ZIP"
SLOT="0"

RESTRICT="bindist"

CDEPEND="
	sys-libs/zlib
"
RDEPEND="
	${CDEPEND}
	!>=games-emulation/snes9x-1.60[libretro]
"
DEPEND="
	${CDEPEND}
"
