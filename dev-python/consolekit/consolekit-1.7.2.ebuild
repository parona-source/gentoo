# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=flit
PYTHON_COMPAT=( python3_{10..13} )

inherit distutils-r1 pypi

DESCRIPTION="Additional utilities for click."
HOMEPAGE="
	https://pypi.org/project/consolekit/
"
# https://github.com/domdfcoding/consolekit/issues/102
SRC_URI="
	https://github.com/domdfcoding/consolekit/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/click-7.1.2[${PYTHON_USEDEP}]
	>=dev-python/deprecation-alias-0.1.1[${PYTHON_USEDEP}]
	>=dev-python/domdf-python-tools-3.8.0[${PYTHON_USEDEP}]
	>=dev-python/mistletoe-0.7.2[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-3.10.0.0[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		>=dev-python/coincidence-0.2.0[${PYTHON_USEDEP}]
		>=dev-python/colorama-0.4.4[${PYTHON_USEDEP}]
		>=dev-python/domdf-python-tools-2.0.1[${PYTHON_USEDEP}]
		>=dev-python/importlib-metadata-3.6.0[${PYTHON_USEDEP}]
		>=dev-python/iniconfig-1.0.1[${PYTHON_USEDEP}]
		>=dev-python/psutil-5.9.6[${PYTHON_USEDEP}]
		>=dev-python/pytest-regressions-2.0.1[${PYTHON_USEDEP}]
		>=dev-python/pytest-timeout-1.4.2[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest
