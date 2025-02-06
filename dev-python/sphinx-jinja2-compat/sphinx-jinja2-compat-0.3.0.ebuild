# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=whey
PYTHON_COMPAT=( python3_{10..13} )

inherit distutils-r1 pypi

DESCRIPTION="Patches Jinja2 v3 to restore compatibility with earlier Sphinx versions."
HOMEPAGE="
	https://github.com/sphinx-toolbox/sphinx-jinja2-compat/
	https://pypi.org/project/sphinx-jinja2-compat/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/jinja2-2.10[${PYTHON_USEDEP}]
	>=dev-python/markupsafe-1[${PYTHON_USEDEP}]
	$(python_gen_cond_dep 'dev-python/standard-imghdr[${PYTHON_USEDEP}]' python3_13)
"
BDEPEND="
	dev-python/whey-pth[${PYTHON_USEDEP}]
"
