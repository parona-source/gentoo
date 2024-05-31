# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )

inherit autotools python-single-r1

MY_P="${P/_rc/-rc}"
MY_SLOT="$(ver_cut 1-2)"

DESCRIPTION="Linux Trace Toolkit - UST library"
HOMEPAGE="https://lttng.org
	https://github.com/lttng/lttng-ust/"
SRC_URI="https://lttng.org/files/${PN}/${MY_P}.tar.bz2"
S="${WORKDIR}/${MY_P}"

LICENSE="GPL-2"
SLOT="0/${MY_SLOT}"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~ppc ~ppc64 ~riscv ~sparc ~x86"
IUSE="examples numa"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

DEPEND="
	dev-libs/userspace-rcu:=
	numa? ( sys-process/numactl )
"
RDEPEND="
	${PYTHON_DEPS}
	${DEPEND}
"

src_prepare() {
	default

	if ! use examples ; then
		sed -i -e '/SUBDIRS/s:examples::' doc/Makefile.am || die
	fi

	eautoreconf
}

src_configure() {
	econf $(use_enable numa)
}

src_install() {
	default

	find "${ED}" -name '*.la' -delete || die

	python_fix_shebang "${ED}"
}
