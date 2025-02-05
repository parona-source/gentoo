# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..13} )

inherit distutils-r1

DESCRIPTION="A simple Python wheel builder for simple projects."
HOMEPAGE="
	https://pypi.org/project/whey/
"
# no tests in sdist
# https://github.com/repo-helper/whey/issues/109
SRC_URI="
	https://github.com/repo-helper/whey/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	>=dev-python/attrs-22.2.0[${PYTHON_USEDEP}]
	>=dev-python/click-7.1.2[${PYTHON_USEDEP}]
	>=dev-python/consolekit-1.4.1[${PYTHON_USEDEP}]
	>=dev-python/dist-meta-0.1.0[${PYTHON_USEDEP}]
	>=dev-python/dom-toml-2.0.0[${PYTHON_USEDEP}]
	>=dev-python/domdf-python-tools-2.8.0[${PYTHON_USEDEP}]
	>=dev-python/handy-archives-0.2.0[${PYTHON_USEDEP}]
	>=dev-python/natsort-7.1.1[${PYTHON_USEDEP}]
	>=dev-python/packaging-20.9[${PYTHON_USEDEP}]
	>=dev-python/pyproject-parser-0.11.0[${PYTHON_USEDEP}]
	>=dev-python/shippinglabel-0.16.0[${PYTHON_USEDEP}]
"

BDEPEND="
	test? (
		>=dev-python/coincidence-0.2.0[${PYTHON_USEDEP}]
		>=dev-python/editables-0.2[${PYTHON_USEDEP}]
		>=dev-python/importlib-metadata-3.6.0[${PYTHON_USEDEP}]
		>=dev-python/iniconfig-1.0.1[${PYTHON_USEDEP}]
		dev-python/pyproject-examples[${PYTHON_USEDEP}]
		>=dev-python/pytest-timeout-1.4.2[${PYTHON_USEDEP}]
		>=dev-python/re-assert-1.1.0[${PYTHON_USEDEP}]
		>=dev-python/whey-pth-0.0.4[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest

EPYTEST_IGNORE=(
	# Avoid whey-conda test dependency
	"tests/test_utils.py"
)

EPYTEST_DESELECT=(
	# Avoid whey-conda test dependency
	"tests/test_cli.py::test_show_builders[binary-binary_conda]"
	"tests/test_cli.py::test_show_builders[binary_and_sdist-binary_conda]"
	"tests/test_cli.py::test_show_builders[none-binary_conda]"
	"tests/test_cli.py::test_show_builders[sdist-binary_conda]"
	"tests/test_cli.py::test_show_builders[wheel-binary_conda]"
	"tests/test_cli.py::test_show_builders[whey_conda-binary_conda]"
	"tests/test_cli.py::test_show_builders[whey_conda-binary_wheel]"
	"tests/test_cli.py::test_show_builders[whey_conda-default]"
	"tests/test_cli.py::test_show_builders[whey_conda-sdist]"
	"tests/test_cli.py::test_show_builders[whey_conda-sdist_and_wheel]"
	"tests/test_cli.py::test_show_builders[whey_conda-wheel]"
	"tests/test_cli.py::test_show_builders[whey_conda-whey_pth]"
	"tests/test_cli.py::test_show_builders[whey_conda_and_sdist-binary_conda]"
	"tests/test_cli.py::test_show_builders[whey_conda_and_sdist-binary_wheel]"
	"tests/test_cli.py::test_show_builders[whey_conda_and_sdist-default]"
	"tests/test_cli.py::test_show_builders[whey_conda_and_sdist-sdist]"
	"tests/test_cli.py::test_show_builders[whey_conda_and_sdist-sdist_and_wheel]"
	"tests/test_cli.py::test_show_builders[whey_conda_and_sdist-wheel]"
	"tests/test_cli.py::test_show_builders[whey_conda_and_sdist-whey_pth]"
	"tests/test_cli.py::test_show_builders[whey_conda_and_whey_pth-binary_conda]"
	"tests/test_cli.py::test_show_builders[whey_conda_and_whey_pth-binary_wheel]"
	"tests/test_cli.py::test_show_builders[whey_conda_and_whey_pth-default]"
	"tests/test_cli.py::test_show_builders[whey_conda_and_whey_pth-sdist]"
	"tests/test_cli.py::test_show_builders[whey_conda_and_whey_pth-sdist_and_wheel]"
	"tests/test_cli.py::test_show_builders[whey_conda_and_whey_pth-wheel]"
	"tests/test_cli.py::test_show_builders[whey_conda_and_whey_pth-whey_pth]"
)
