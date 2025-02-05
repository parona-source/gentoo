# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..13} )

inherit distutils-r1

DESCRIPTION="Utilities for handling packages."
HOMEPAGE="
	https://pypi.org/project/shippinglabel/
"
# https://github.com/domdfcoding/shippinglabel/issues/91
SRC_URI="
	https://github.com/domdfcoding/shippinglabel/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/dist-meta-0.1.2[${PYTHON_USEDEP}]
	>=dev-python/dom-toml-0.2.2[${PYTHON_USEDEP}]
	>=dev-python/domdf-python-tools-3.1.0[${PYTHON_USEDEP}]
	>=dev-python/packaging-20.9[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-3.7.4.3[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		>=dev-python/apeye-1.0.0[${PYTHON_USEDEP}]
		>=dev-python/betamax-0.8.1[${PYTHON_USEDEP}]
		>=dev-python/coincidence-0.2.0[${PYTHON_USEDEP}]
		>=dev-python/consolekit-1.1.2[${PYTHON_USEDEP}]
		>=dev-python/importlib-metadata-3.6.0[${PYTHON_USEDEP}]
		>=dev-python/pip-21[${PYTHON_USEDEP}]
		>=dev-python/pytest-regressions-2.0.2[${PYTHON_USEDEP}]
		>=dev-python/pytest-rerunfailures-9.1.1[${PYTHON_USEDEP}]
		>=dev-python/pytest-timeout-1.4.2[${PYTHON_USEDEP}]
		>=dev-python/requests-2.25.1[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest

EPYTEST_IGNORE=(
	# Fetches files from github
	"tests/test_checksum.py"
)

EPYTEST_DESELECT=(
	# pypi sdists for requests are generated in non PEP517 method meaning its
	# Requires-Dist isn't normalized. Meanwhile gentoo generates all its packages
	# with PEP517 leading to mismatched expectations with charset-normalizer.
	# Handling for this should be changed either in this package or dist_meta
	# for consistent ouput.
	"tests/test_requirements.py::test_list_requirements[-1-apeye-3.10]"
	"tests/test_requirements.py::test_list_requirements[2-apeye-3.10]"
	"tests/test_requirements.py::test_list_requirements[3-apeye-3.10]"
	"tests/test_requirements.py::test_list_requirements[-1-cachecontrol[filecache]-3.10]"
	"tests/test_requirements.py::test_list_requirements[2-cachecontrol[filecache]-3.10]"
	"tests/test_requirements.py::test_list_requirements[3-cachecontrol[filecache]-3.10]"
)
