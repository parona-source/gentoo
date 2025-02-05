# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
EPYTEST_XDIST=1
PYTHON_COMPAT=( python3_{10..13} )

inherit distutils-r1

DESCRIPTION="Parse and create Python distribution metadata."
HOMEPAGE="
	https://pypi.org/project/dist-meta/
"
#https://github.com/repo-helper/dist-meta/issues/51
SRC_URI="
	https://github.com/repo-helper/dist-meta/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/domdf-python-tools-3.1.0[${PYTHON_USEDEP}]
	>=dev-python/handy-archives-0.1.0[${PYTHON_USEDEP}]
	>=dev-python/packaging-20.9[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		>=dev-python/apeye-1.0.1[${PYTHON_USEDEP}]
		>=dev-python/atomicwrites-1.4.1[${PYTHON_USEDEP}]
		>=dev-python/attrs-22.2.0[${PYTHON_USEDEP}]
		>=dev-python/coincidence-0.2.0[${PYTHON_USEDEP}]
		>=dev-python/colorama-0.4.5[${PYTHON_USEDEP}]
		>=dev-python/consolekit-1.2.3[${PYTHON_USEDEP}]
		>=dev-python/first-2.0.2[${PYTHON_USEDEP}]
		>=dev-python/importlib-metadata-3.6.0[${PYTHON_USEDEP}]
		>=dev-python/pypi-json-0.2.1[${PYTHON_USEDEP}]
		>=dev-python/pytest-rerunfailures-10.1[${PYTHON_USEDEP}]
		>=dev-python/pytest-timeout-1.4.2[${PYTHON_USEDEP}]
		>=dev-python/pytz-2022.7.1[${PYTHON_USEDEP}]
		>=dev-python/shippinglabel-0.16.0[${PYTHON_USEDEP}]
		>=dev-python/sphinx-4.0.2[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest

EPYTEST_DESELECT=(
	# Hammers pypi and is slooow
	"tests/test_metadata_top_packages.py::test_loads"
	# Test expects specific venv packages to be installed
	"tests/test_distributions.py::test_packages_distributions"
)
