# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{10..13} )

inherit distutils-r1

DESCRIPTION="Core (offline) functionality for the apeye library."
HOMEPAGE="
	https://github.com/domdfcoding/apeye-core/
	https://pypi.org/project/apeye-core/
"
#https://github.com/domdfcoding/apeye-core/issues/33
SRC_URI="
	https://github.com/domdfcoding/apeye-core/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/domdf-python-tools-2.6.0[${PYTHON_USEDEP}]
	>=dev-python/idna-2.5[${PYTHON_USEDEP}]
"
BDEPEND="
	dev-python/hatch-requirements-txt[${PYTHON_USEDEP}]
	test? (
		>=dev-python/coincidence-0.2.0[${PYTHON_USEDEP}]
		>=dev-python/importlib-metadata-3.6.0[${PYTHON_USEDEP}]
		>=dev-python/pytest-httpserver-0.3.5[${PYTHON_USEDEP}]
		>=dev-python/pytest-timeout-1.4.2[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest
