# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=flit
EPYTEST_XDIST=1
PYTHON_COMPAT=( python3_{10..13} )

inherit distutils-r1

DESCRIPTION="Handy tools for working with URLs and APIs."
HOMEPAGE="
	https://github.com/domdfcoding/apeye/
	https://pypi.org/project/apeye/
"
# https://github.com/domdfcoding/apeye/issues/89
SRC_URI="
	https://github.com/domdfcoding/apeye/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/apeye-core-1.1.4[${PYTHON_USEDEP}]
	>=dev-python/domdf-python-tools-2.6.0[${PYTHON_USEDEP}]
	>=dev-python/platformdirs-2.3.0[${PYTHON_USEDEP}]
	>=dev-python/requests-2.24.0[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		>=dev-python/cachecontrol-0.12.6[${PYTHON_USEDEP}]
		>=dev-python/cherrypy-18.8.0[${PYTHON_USEDEP}]
		>=dev-python/coincidence-0.2.0[${PYTHON_USEDEP}]
		>=dev-python/filelock-3.8.0[${PYTHON_USEDEP}]
		>=dev-python/importlib-metadata-3.6.0[${PYTHON_USEDEP}]
		>=dev-python/pytest-httpserver-0.3.5[${PYTHON_USEDEP}]
		>=dev-python/pytest-timeout-1.4.2[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest

EPYTEST_DESELECT=(
	# network test
	"tests/test_url.py::TestRequestsURL::test_get"
	"tests/test_url.py::TestRequestsURL::test_resolve"
	"tests/test_url.py::TestSlumberURL::test_delete"
	"tests/test_url.py::TestSlumberURL::test_get"
	"tests/test_url.py::TestSlumberURL::test_head"
	"tests/test_url.py::TestSlumberURL::test_options"
	"tests/test_url.py::TestSlumberURL::test_patch"
	"tests/test_url.py::TestSlumberURL::test_post"
	"tests/test_url.py::TestSlumberURL::test_put"
	"tests/test_url.py::TestTrailingRequestsURL::test_get"
	"tests/test_url.py::TestTrailingRequestsURL::test_resolve"
	# timing test may be affected by system load
	"tests/test_rate_limiter.py::test_rate_limit"
	"tests/test_rate_limiter.py::test_http_cache"
)
