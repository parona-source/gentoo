# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=whey
PYTHON_COMPAT=( python3_{10..13} )

inherit distutils-r1

DESCRIPTION="PyPI JSON API client library"
HOMEPAGE="
	https://github.com/repo-helper/pypi-json/
	https://pypi.org/project/pypi-json/
"
# https://github.com/repo-helper/pypi-json/issues/37
SRC_URI="
	https://github.com/repo-helper/pypi-json/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/apeye-1.1.0[${PYTHON_USEDEP}]
	>=dev-python/packaging-21.0[${PYTHON_USEDEP}]
	>=dev-python/requests-2.26.0[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		>=dev-python/betamax-0.8.1[${PYTHON_USEDEP}]
		>=dev-python/coincidence-0.2.0[${PYTHON_USEDEP}]
		>=dev-python/importlib-metadata-3.6.0[${PYTHON_USEDEP}]
		>=dev-python/pytest-timeout-1.4.2[${PYTHON_USEDEP}]
		>=dev-python/shippinglabel-1.0.0[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest

EPYTEST_DESELECT=(
	# network sandbox
	"tests/test_api.py::test_changes_to_api_july_2022"
	"tests/test_api.py::test_download_file"
)
