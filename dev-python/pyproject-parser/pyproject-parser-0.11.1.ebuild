# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
EPYTEST_XDIST=1
PYTHON_COMPAT=( python3_{10..13} )

inherit distutils-r1

DESCRIPTION="Parser for 'pyproject.toml'"
HOMEPAGE="
	https://github.com/repo-helper/pyproject-parser/
	https://pypi.org/project/pyproject-parser/
"
#https://github.com/repo-helper/pyproject-parser/issues/69
SRC_URI="
	https://github.com/repo-helper/pyproject-parser/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/apeye-core-1.0.0[${PYTHON_USEDEP}]
	>=dev-python/attrs-20.3.0[${PYTHON_USEDEP}]
	>=dev-python/dom-toml-2.0.0[${PYTHON_USEDEP}]
	>=dev-python/domdf-python-tools-2.8.0[${PYTHON_USEDEP}]
	>=dev-python/natsort-7.1.1[${PYTHON_USEDEP}]
	>=dev-python/packaging-20.9[${PYTHON_USEDEP}]
	>=dev-python/shippinglabel-1.0.0[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-3.7.4.3[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		>=dev-python/click-7.1.2[${PYTHON_USEDEP}]
		>=dev-python/coincidence-0.2.0[${PYTHON_USEDEP}]
		>=dev-python/consolekit-1.4.1[${PYTHON_USEDEP}]
		>=dev-python/importlib-metadata-3.6.0[${PYTHON_USEDEP}]
		>=dev-python/pyproject-examples-2023.6.30[${PYTHON_USEDEP}]
		>=dev-python/pytest-timeout-1.4.2[${PYTHON_USEDEP}]
		>=dev-python/sdjson-0.3.1[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest
