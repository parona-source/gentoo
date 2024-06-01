# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CODENAME="Omega"

inherit kodi-addon-r1

DESCRIPTION="Matrix Trails screensaver for Kodi"
HOMEPAGE="https://github.com/xbmc/screensaver.matrixtrails"

LICENSE="GPL-2"
SLOT="0"

RDEPEND="
	media-libs/libglvnd
"
DEPEND="
	${RDEPEND}
"
