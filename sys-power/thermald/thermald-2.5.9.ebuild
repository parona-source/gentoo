# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools linux-info out-of-source systemd

DESCRIPTION="Thermal daemon for Intel architectures"
HOMEPAGE="https://github.com/intel/thermal_daemon"
SRC_URI="https://github.com/intel/thermal_daemon/archive/v${PV}.tar.gz -> ${P}.tar.gz"
S=${WORKDIR}/thermal_daemon-${PV}

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64 x86"

RDEPEND="
	dev-libs/glib:=
	dev-libs/libxml2:=
	dev-libs/libevdev
	sys-power/upower
	sys-apps/dbus:="
DEPEND="${RDEPEND}
	dev-util/gtk-doc
	dev-util/glib-utils"

DOCS=( thermal_daemon_usage.txt README.txt )

CONFIG_CHECK="~PERF_EVENTS_INTEL_RAPL ~X86_INTEL_PSTATE ~INTEL_POWERCLAMP ~INT340X_THERMAL ~ACPI_THERMAL_REL ~INT3406_THERMAL"

src_prepare() {
	sed -i -e '/tdrundir/s@\$localstatedir/run@\$runstatedir@' \
		configure.ac || die

	sed -i -e 's@\$(AM_V_GEN) glib-compile-resources@cd \$(top_srcdir) \&\& &@' \
		Makefile.am || die

	default
	eautoreconf
}

my_src_configure() {
	ECONF_SOURCE="${S}" econf \
		--disable-werror \
		--runstatedir="${EPREFIX}"/run \
		--with-dbus-power-group=wheel \
		--with-systemdsystemunitdir="$(systemd_get_systemunitdir)"
}

my_src_install_all() {
	einstalldocs

	rm -rf "${ED}"/etc/init || die
	doinitd "${FILESDIR}"/thermald
}
