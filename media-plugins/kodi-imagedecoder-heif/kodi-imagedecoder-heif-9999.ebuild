# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CODENAME="Omega"

inherit kodi-addon-r1

DESCRIPTION="HEIF image decoder for Kodi"
HOMEPAGE="https://github.com/xbmc/imagedecoder.heif"

LICENSE="GPL-2"
SLOT="0"

RDEPEND="
	dev-libs/tinyxml2:=
	media-libs/libheif:=
"
DEPEND="
	${RDEPEND}
	media-libs/libde265
"
