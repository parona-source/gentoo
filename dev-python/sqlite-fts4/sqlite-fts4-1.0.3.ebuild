# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )
PYTHON_REQ_USE="sqlite"

inherit distutils-r1

DESCRIPTION="Custom Python functions for working with SQLite FTS4"
HOMEPAGE="
	https://github.com/simonw/sqlite-fts4/
	https://pypi.org/project/sqlite-fts4/
"
# no tests in sdist
SRC_URI="
	https://github.com/simonw/sqlite-fts4/archive/refs/tags/${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest
