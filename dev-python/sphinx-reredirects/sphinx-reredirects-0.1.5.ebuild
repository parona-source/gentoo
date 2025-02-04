# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..13} )

inherit distutils-r1

DESCRIPTION="Handles redirects for moved pages in Sphinx documentation projects"
HOMEPAGE="
	https://github.com/documatt/sphinx-reredirects/
	https://pypi.org/project/sphinx-reredirects/
"
# test files missing in sdist
SRC_URI="
	https://github.com/documatt/sphinx-reredirects/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/sphinx-7.1[${PYTHON_USEDEP}]
"

distutils_enable_tests pytest

EPYTEST_DESELECT=(
	# Runs linkcheck on upstrem documentation
	"tests/test_end2end.py::test_linkcheck"
)
