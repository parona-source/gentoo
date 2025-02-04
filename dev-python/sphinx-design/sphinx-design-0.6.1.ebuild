# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=flit
PYTHON_COMPAT=( python3_{10..13} )

inherit distutils-r1

DESCRIPTION="A sphinx extension for designing beautiful, view size responsive web components."
HOMEPAGE="
	https://github.com/executablebooks/sphinx-design/
	https://pypi.org/project/sphinx-design/
"
# no tests in sdist
SRC_URI="
	https://github.com/executablebooks/sphinx-design/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	<dev-python/sphinx-9[${PYTHON_USEDEP}]
	>=dev-python/sphinx-6[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		dev-python/defusedxml[${PYTHON_USEDEP}]
		dev-python/myst-parser[${PYTHON_USEDEP}]
		dev-python/pytest-regressions[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest
