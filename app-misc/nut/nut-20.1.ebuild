# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs

DESCRIPTION="Record what you eat and analyze your nutrient levels"
HOMEPAGE="https://nut.sourceforge.net/"
SRC_URI="https://downloads.sourceforge.net/${PN}/${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ppc x86"

src_compile() {
	emake \
		CC="$(tc-getCC)" \
		OPT="${CFLAGS}" \
		FOODDIR=\\\"/usr/share/nut\\\" \
		nut
}

src_install() {
	insinto /usr/share/nut
	doins raw.data/*

	dobin nut
	doman nut.1
}
