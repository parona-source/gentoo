# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: mysql.eclass
# @MAINTAINER:
# Alfred Wingate <parona@protonmail.com>
# @AUTHOR:
# Alfred Wingate <parona@protonmail.com>
# @SUPPORTED_EAPIS: 8
# @BLURB:
# @DESCRIPTION:

case ${EAPI} in
	8) ;;
	*) die "${ECLASS}: EAPI ${EAPI:-0} not supported" ;;
esac

if [[ ! ${_MYSQL_ECLASS} ]]; then
_MYSQL_ECLASS=1

_MYSQL_ALL_VERSIONS=( mysql_8.4 mysql_8.0 )

MYSQL_DEP="|| ("
for slot in "${_MYSQL_ALL_VERSIONS[@]}" ; do
	MYSQL_DEP+=" dev-db/${slot%%-*}:${slot%%*-}[server]"
done
MYSQL_DEP+=" )"

mysql_pkg_setup() {
	for slot in "${_MYSQL_ALL_VERSIONS[@]}" ; do
		if [[ -e "/usr/$(get_libdir)/${slot/_/-}/sbin/mysqld" ]]; then
			export PATH="/usr/$(get_libdir)/${slot/_/-}/bin/:/usr/$(get_libdir)/${slot/_/-}/sbin/:${PATH}"
			return 0
		fi
	done
	die "Couldn't find acceptable mysql"
}

fi
