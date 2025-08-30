# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=poetry
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1

DESCRIPTION="The sweeter pytest snapshot plugin"
HOMEPAGE="
	https://github.com/syrupy-project/syrupy/
	https://pypi.org/project/syrupy/
"
# no tests in sdist
SRC_URI="
	https://github.com/syrupy-project/syrupy/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/pytest-8[${PYTHON_USEDEP}]
"

EPYTEST_PLUGINS=( pytest-xdist syrupy ) # xdist used in pytest subprocesses
EPYTEST_PLUGIN_LOAD_VIA_ENV=1
distutils_enable_tests pytest
