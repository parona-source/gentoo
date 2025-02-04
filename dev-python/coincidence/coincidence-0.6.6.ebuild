# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=whey
PYTHON_COMPAT=( python3_{10..13} )

inherit distutils-r1

DESCRIPTION="Helper functions for pytest."
HOMEPAGE="
	https://github.com/python-coincidence/coincidence/
	https://pypi.org/project/coincidence/
"
# https://github.com/python-coincidence/coincidence/issues/79
SRC_URI="
	https://github.com/python-coincidence/coincidence/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

PATCHES=(
	"${FILESDIR}"/coincidence-0.6.6-no-toml.patch
)

RDEPEND="
	>=dev-python/domdf-python-tools-2.8.0[${PYTHON_USEDEP}]
	>=dev-python/pytest-6.2.0[${PYTHON_USEDEP}]
	>=dev-python/pytest-regressions-2.0.2[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-3.7.4.3[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		>=dev-python/domdf-python-tools-2.0.1[${PYTHON_USEDEP}]
		>=dev-python/importlib-metadata-3.6.0[${PYTHON_USEDEP}]
		>=dev-python/iniconfig-1.0.1[${PYTHON_USEDEP}]
		>=dev-python/pytest-timeout-1.4.2[${PYTHON_USEDEP}]
		$(python_gen_cond_dep '>=dev-python/tomli-1.2.3[${PYTHON_USEDEP}]' python3_10)
	)
"

distutils_enable_tests pytest
