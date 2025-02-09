# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=whey
PYTHON_COMPAT=( python3_{10..13} )

inherit distutils-r1

DESCRIPTION="JSON Encoder for Python utilising functools.singledispatch"
HOMEPAGE="
	https://github.com/domdfcoding/singledispatch-json/
	https://pypi.org/project/sdjson/
"
# https://github.com/domdfcoding/singledispatch-json/issues/53
SRC_URI="
	https://github.com/domdfcoding/singledispatch-json/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"
S="${WORKDIR}/singledispatch-json-${PV}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/domdf-python-tools-2.5.2[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-3.7.4.3[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		>=dev-python/coincidence-0.2.0[${PYTHON_USEDEP}]
		>=dev-python/importlib-metadata-3.6.0[${PYTHON_USEDEP}]
		>=dev-python/iniconfig-1.0.1[${PYTHON_USEDEP}]
		>=dev-python/pytest-rerunfailures-9.0[${PYTHON_USEDEP}]
		>=dev-python/pytest-timeout-1.4.2[${PYTHON_USEDEP}]
		>=dev-python/pytz-2019.1[${PYTHON_USEDEP}]
	)
"

PATCHES=(
	"${FILESDIR}"/sdjson-0.5.0-fix-python3.13.patch
)

distutils_enable_tests pytest
