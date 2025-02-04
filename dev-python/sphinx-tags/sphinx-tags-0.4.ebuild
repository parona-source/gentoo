# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=flit
PYTHON_COMPAT=( python3_{10..13} )

inherit distutils-r1 pypi

DESCRIPTION="Sphinx extension to create tags for documentation pages."
HOMEPAGE="
	https://github.com/melissawm/sphinx-tags/
	https://pypi.org/project/sphinx-tags/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/sphinx-5.1[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		dev-python/beautifulsoup4[${PYTHON_USEDEP}]
		dev-python/nbsphinx[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest
