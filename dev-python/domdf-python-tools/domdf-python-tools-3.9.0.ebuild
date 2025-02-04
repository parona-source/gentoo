# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..13} )

inherit distutils-r1 pypi

DESCRIPTION="Helpful functions for Python"
HOMEPAGE="
	https://github.com/domdfcoding/domdf_python_tools/
	https://pypi.org/project/domdf-python-tools/
"
# https://github.com/domdfcoding/domdf_python_tools/issues/114
SRC_URI="
	https://github.com/domdfcoding/domdf_python_tools/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/natsort[${PYTHON_USEDEP}]
	dev-python/typing-extensions[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		>=dev-python/click-7.1.2[${PYTHON_USEDEP}]
		>=dev-python/coincidence-0.2.0[${PYTHON_USEDEP}]
		>=dev-python/consolekit-1.0.0[${PYTHON_USEDEP}]
		>=dev-python/faker-4.1.2[${PYTHON_USEDEP}]
		>=dev-python/funcy-1.16[${PYTHON_USEDEP}]
		>=dev-python/importlib-metadata-3.6.0[${PYTHON_USEDEP}]
		>=dev-python/pytest-regressions-2.0.1[${PYTHON_USEDEP}]
		>=dev-python/pytest-rerunfailures-9.1.1[${PYTHON_USEDEP}]
		>=dev-python/pytest-timeout-1.4.2[${PYTHON_USEDEP}]
		>=dev-python/pytz-2019.1[${PYTHON_USEDEP}]
		$(python_gen_cond_dep '>=dev-python/pandas-1.0.0[${PYTHON_USEDEP}]' python3_10)
	)
"

# Lots of smalls tests but not xdist friendly
distutils_enable_tests pytest

EPYTEST_IGNORE=(
	# Uses internal test stdlib
	"tests/test_paths_stdlib.py"
)

EPYTEST_DESELECT=(
	# https://github.com/domdfcoding/domdf_python_tools/issues/82
	"tests/test_import_tools.py::test_discover_entry_points"
	"tests/test_import_tools.py::test_discover_entry_points_by_name_name_match_func"
	"tests/test_import_tools.py::test_discover_entry_points_by_name_object_match_func"
)
