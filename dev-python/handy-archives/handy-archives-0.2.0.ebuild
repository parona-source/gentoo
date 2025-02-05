# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=flit
PYTHON_COMPAT=( python3_{10..13} )

inherit distutils-r1

DESCRIPTION="Some handy archive helpers for Python."
HOMEPAGE="
	https://pypi.org/project/handy-archives/
"
# https://github.com/domdfcoding/handy-archives/issues/33
SRC_URI="
	https://github.com/domdfcoding/handy-archives/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

BDEPEND="
	test? (
		>=dev-python/coincidence-0.2.0[${PYTHON_USEDEP}]
		>=dev-python/importlib-metadata-3.6.0[${PYTHON_USEDEP}]
		>=dev-python/pytest-timeout-1.4.2[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest

EPYTEST_IGNORE=(
	# Uses internal test stdblib
	"tests/test_tarfile.py"
	"tests/test_unpack_archive.py"
	"tests/test_zipfile.py"
)
