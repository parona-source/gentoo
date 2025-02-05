# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=hatchling
PYTHON_COMPAT=( python3_{10..13} )

inherit distutils-r1

DESCRIPTION="Hatchling plugin to read project dependencies from requirements.txt"
HOMEPAGE="
	https://github.com/repo-helper/hatch-requirements-txt/
	https://pypi.org/project/hatch-requirements-txt/
"
# https://github.com/repo-helper/hatch-requirements-txt/issues/65
SRC_URI="
	https://github.com/repo-helper/hatch-requirements-txt/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/packaging[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		>=dev-python/coincidence-0.2.0[${PYTHON_USEDEP}]
		>=dev-python/dist-meta-0.5.0[${PYTHON_USEDEP}]
		>=dev-python/domdf-python-tools-3.3.0[${PYTHON_USEDEP}]
		>=dev-python/importlib-metadata-3.6.0[${PYTHON_USEDEP}]
		>=dev-python/pkginfo-1.8.3[${PYTHON_USEDEP}]
		>=dev-python/pytest-timeout-1.4.2[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest

EPYTEST_DESELECT=(
	# https://github.com/repo-helper/hatch-requirements-txt/issues/62
	"tests/test_errors.py::test_not_dynamic_but_files_defined[build_sdist]"
	"tests/test_errors.py::test_not_dynamic_but_filename_defined[build_wheel]"
	"tests/test_errors.py::test_not_dynamic_but_filename_defined[build_sdist]"
	"tests/test_errors.py::test_not_dynamic_but_files_defined[build_wheel]"
)
