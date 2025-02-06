# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=whey
PYTHON_COMPAT=( python3_{10..13} )

inherit distutils-r1 pypi

DESCRIPTION="A μ-library for constructing cascading style sheets from Python dictionaries."
HOMEPAGE="
	https://github.com/sphinx-toolbox/dict2css/
	https://pypi.org/project/dict2css/
"
# no tests in sdist
SRC_URI="
	https://github.com/sphinx-toolbox/dict2css/archive/refs/tags/v$(pypi_translate_version ${PV}).tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/cssutils-2.2.0[${PYTHON_USEDEP}]
	>=dev-python/domdf-python-tools-2.2.0[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		>=dev-python/coincidence-0.2.0[${PYTHON_USEDEP}]
		>=dev-python/importlib-metadata-3.6.0[${PYTHON_USEDEP}]
		>=dev-python/iniconfig-1.0.1[${PYTHON_USEDEP}]
		>=dev-python/pytest-timeout-1.4.2[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest
