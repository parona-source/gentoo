# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="Tiny library to interface with ALSA in the Linux kernel"
HOMEPAGE="https://github.com/tinyalsa/tinyalsa"
SRC_URI="
	https://github.com/tinyalsa/tinyalsa/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.tar.gz
"

LICENSE="BSD"
SLOT="0/$(ver_cut 1)"
KEYWORDS="~amd64"

IUSE="examples tools"

# Tests use bazel and require loopback devices
RESTRICT="test"

BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}"/tinyalsa-2.0.0-fix-include-install.patch
)

src_configure() {
	local emesonargs=(
		-Ddocs=disabled # not hooked up upstream
		-Dexamples=disabled # not installed
		$(meson_feature tools utils)
	)
	meson_src_configure
}
