# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{11..13} )

inherit distutils-r1 pypi

DESCRIPTION="The official Python library for the openai API"
HOMEPAGE="
	https://github.com/openai/openai-python/
	https://pypi.org/project/openai/
"
# missing test files (inline-snapshot .bins)
SRC_URI="
	https://github.com/openai/openai-python/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"
S="${WORKDIR}/openai-python-${PV}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/httpx[${PYTHON_USEDEP}]
	<dev-python/pydantic-3[${PYTHON_USEDEP}]
	>=dev-python/pydantic-1.9.0[${PYTHON_USEDEP}]
	<dev-python/typing-extensions-5[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-4.11[${PYTHON_USEDEP}]
	<dev-python/anyio-5[${PYTHON_USEDEP}]
	>=dev-python/anyio-3.5.0[${PYTHON_USEDEP}]
	<dev-python/distro-2[${PYTHON_USEDEP}]
	>=dev-python/distro-1.7.0[${PYTHON_USEDEP}]
	dev-python/sniffio[${PYTHON_USEDEP}]
	>dev-python/tqdm-4-r9999[${PYTHON_USEDEP}]
	<dev-python/jiter-1[${PYTHON_USEDEP}]
	>=dev-python/jiter-0.4.0[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		dev-python/time-machine[${PYTHON_USEDEP}]
		>=dev-python/dirty-equals-0.6.0[${PYTHON_USEDEP}]
		>=dev-python/importlib-metadata-6.7.0[${PYTHON_USEDEP}]
		>=dev-python/rich-13.7.1[${PYTHON_USEDEP}]
		>=dev-python/inline-snapshot-0.7.0[${PYTHON_USEDEP}]
		>=dev-python/trio-0.22.2[${PYTHON_USEDEP}]
		dev-python/nest-asyncio[${PYTHON_USEDEP}]
		>=dev-python/griffe-1[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=( inline-snapshot pytest-asyncio respx )
EPYTEST_XDIST=1
distutils_enable_tests pytest

EPYTEST_IGNORE=(
	# requires a mock server, needs setup
	tests/api_resources/
)
