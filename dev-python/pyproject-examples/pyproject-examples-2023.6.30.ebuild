# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=whey
PYTHON_COMPAT=( python3_{10..13} )

inherit distutils-r1 pypi

DESCRIPTION="Example pyproject.toml configs for testing."
HOMEPAGE="
	https://github.com/repo-helper/pyproject-examples/
	https://pypi.org/project/pyproject-examples/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/coincidence-0.4.0[${PYTHON_USEDEP}]
	>=dev-python/dom-toml-0.4.0[${PYTHON_USEDEP}]
	>=dev-python/packaging-21.3[${PYTHON_USEDEP}]
	>=dev-python/pytest-6.2.3[${PYTHON_USEDEP}]
"
