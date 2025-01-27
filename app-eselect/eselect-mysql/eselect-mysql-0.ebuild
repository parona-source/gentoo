# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit prefix

DESCRIPTION="Utility to select the default MySQL slot"
HOMEPAGE="https://wiki.gentoo.org/wiki/No_homepage"

S="${WORKDIR}"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~mips ~ppc64 ~riscv ~s390 ~sparc ~x86 ~amd64-linux ~x86-linux ~x64-macos ~x64-solaris"

RDEPEND="
	app-admin/eselect
	!dev-db/mariadb
	!dev-db/mariadb-galera
	!dev-db/percona-server
	!dev-db/mysql-cluster
	!dev-db/mysql:0
	!dev-db/mysql:5.7
	!<dev-db/mysql-8.0.42-r100:8.0
	!<dev-db/mysql-8.4.5-r100:8.4
"

src_install() {
	# Allows users to share configs between versions
	insinto /etc/mysql
	newins "$(prefixify_ro "${FILESDIR}"/my.cnf)" my.cnf
	keepdir /etc/mysql/mysql.d/

	insinto /usr/share/eselect/modules
	doins "${FILESDIR}"/mysql.eselect

	dosym eselect /usr/bin/mysql-config
}

#pkg_postinst() {
#	mysql-config update
#}
