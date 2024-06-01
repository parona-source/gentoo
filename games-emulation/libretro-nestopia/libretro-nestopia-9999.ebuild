# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LIBRETRO_REPO_NAME="libretro/nestopia"
inherit libretro-core

DESCRIPTION="Nestopia libretro port"

S="${WORKDIR}/nestopia-${LIBRETRO_COMMIT_SHA}/libretro"
LIBRETRO_CORE_LIB_FILE="${S}/${LIBRETRO_CORE_NAME}_libretro.so"
LICENSE="GPL-2+"
SLOT="0"
