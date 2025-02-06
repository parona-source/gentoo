# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..13} )

inherit distutils-r1

DESCRIPTION="Extension to whey to support .pth files."
HOMEPAGE="
	https://github.com/repo-helper/whey-pth/
	https://pypi.org/project/whey-pth/
"
SRC_URI="
	https://github.com/repo-helper/whey-pth/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/dom-toml-0.4.0[${PYTHON_USEDEP}]
	>=dev-python/whey-0.0.26[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		>=dev-python/coincidence-0.2.0[${PYTHON_USEDEP}]
		>=dev-python/domdf-python-tools-2.0.1[${PYTHON_USEDEP}]
		>=dev-python/importlib-metadata-3.6.0[${PYTHON_USEDEP}]
		>=dev-python/iniconfig-1.0.1[${PYTHON_USEDEP}]
		>=dev-python/pytest-timeout-1.4.2[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest
