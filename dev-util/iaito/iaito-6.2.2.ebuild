# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )
inherit meson python-any-r1 xdg

DESCRIPTION="Official radare2 GUI"
HOMEPAGE="https://www.radare.org/n/iaito.html"
SRC_URI="
	https://github.com/radareorg/iaito/archive/refs/tags/${PV}.tar.gz
		-> ${P}.tar.gz
"

EMESON_SOURCE="${S}/src"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64"

IUSE="debugger"

DEPEND="
	dev-qt/qtbase:6[gui]
	dev-qt/qtsvg:6
	dev-util/radare2:=
"
RDEPEND="
	${DEPEND}
	debugger? ( dev-debug/gdb )
"
BDEPEND="
	${PYTHON_DEPS}
	virtual/pkgconfig
"

src_configure() {
	local emesonargs=(
		-Dwith_qt6=true
		$(meson_use debugger with_debugger)
	)
	meson_src_configure
}
