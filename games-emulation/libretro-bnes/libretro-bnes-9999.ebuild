# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LIBRETRO_REPO_NAME="libretro/bnes-libretro"
inherit libretro-core

DESCRIPTION="bNES libretro port"
LICENSE="GPL-3+"
SLOT="0"

RESTRICT="test" # no tests, default phase leads to failure if unrestricted
