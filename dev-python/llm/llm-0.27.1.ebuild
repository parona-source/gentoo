# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..13} )

inherit distutils-r1 pypi

DESCRIPTION="CLI utility and Python library for interacting with Large Language Models"
HOMEPAGE="
	https://llm.datasette.io/
	https://github.com/simonw/llm
	https://pypi.org/project/llm/
"

LLM_ECHO_PV="0.3a3"
# no tests in sdist
SRC_URI="
	https://github.com/simonw/llm/archive/refs/tags/${PV}.tar.gz
		-> ${P}.gh.tar.gz
	test? (
		$(pypi_sdist_url llm_echo ${LLM_ECHO_PV})
	)
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/click[${PYTHON_USEDEP}]
	dev-python/condense-json[${PYTHON_USEDEP}]
	dev-python/openai[${PYTHON_USEDEP}]
	dev-python/click-default-group[${PYTHON_USEDEP}]
	dev-python/sqlite-utils[${PYTHON_USEDEP}]
	dev-python/sqlite-migrate[${PYTHON_USEDEP}]
	dev-python/pydantic[${PYTHON_USEDEP}]
	dev-python/pyyaml[${PYTHON_USEDEP}]
	dev-python/pluggy[${PYTHON_USEDEP}]
	dev-python/python-ulid[${PYTHON_USEDEP}]
	dev-python/setuptools[${PYTHON_USEDEP}]
	dev-python/pip[${PYTHON_USEDEP}]
	dev-python/puremagic[${PYTHON_USEDEP}]
"
# <click-8.2: https://github.com/simonw/llm/issues/1024
BDEPEND="
	test? (
		dev-python/build[${PYTHON_USEDEP}]
		<dev-python/click-8.2[${PYTHON_USEDEP}]
		dev-python/numpy[${PYTHON_USEDEP}]
		dev-python/cogapp[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=( pytest-asyncio pytest-httpx pytest-recording syrupy )
distutils_enable_tests pytest

python_test() {
	local EPYTEST_DESELECT=(
		tests/test_templates.py::test_templates_list
	)

	cp -a "${BUILD_DIR}"/{install,test} || die
	local -x PATH=${BUILD_DIR}/test/usr/bin:${PATH}

	pushd "${WORKDIR}/llm_echo-${LLM_ECHO_PV}" >/dev/null || die
	distutils_pep517_install "${BUILD_DIR}"/test
	popd >/dev/null || die

	local -x COLUMN=80 LINES=24

	epytest
}
