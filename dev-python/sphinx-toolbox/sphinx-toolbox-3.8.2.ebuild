# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=whey
PYTHON_COMPAT=( python3_{10..13} )

inherit distutils-r1

DESCRIPTION="Box of handy tools for Sphinx"
HOMEPAGE="
	https://github.com/sphinx-toolbox/sphinx-toolbox/
	https://pypi.org/project/sphinx-toolbox/
"
# tests missing from sdist
SRC_URI="
	https://github.com/sphinx-toolbox/sphinx-toolbox/archive/refs/tags/v${PV}.tar.gz
		-> ${P}.gh.tar.gz
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

PROPERTIES="test_network"
RESTRICT="test"

# incompatible with sphinx-8.1
# different output and
# https://github.com/sphinx-doc/sphinx/commit/fadb6b10cb15d2a8ce336cee307dcb3ff64680bd
RDEPEND="
	>=dev-python/apeye-0.4.0[${PYTHON_USEDEP}]
	>=dev-python/autodocsumm-0.2.0[${PYTHON_USEDEP}]
	>=dev-python/beautifulsoup4-4.9.1[${PYTHON_USEDEP}]
	>=dev-python/cachecontrol-0.13.0[${PYTHON_USEDEP}]
	>=dev-python/dict2css-0.2.3[${PYTHON_USEDEP}]
	>=dev-python/docutils-0.16[${PYTHON_USEDEP}]
	>=dev-python/domdf-python-tools-2.9.0[${PYTHON_USEDEP}]
	>=dev-python/filelock-3.8.0[${PYTHON_USEDEP}]
	>=dev-python/html5lib-1.1[${PYTHON_USEDEP}]
	>=dev-python/ruamel-yaml-0.16.12[${PYTHON_USEDEP}]
	<dev-python/sphinx-8.1.0[${PYTHON_USEDEP}]
	>=dev-python/sphinx-3.2.0[${PYTHON_USEDEP}]
	>=dev-python/sphinx-autodoc-typehints-1.11.1[${PYTHON_USEDEP}]
	>=dev-python/sphinx-jinja2-compat-0.1.0[${PYTHON_USEDEP}]
	>=dev-python/sphinx-prompt-1.1.0[${PYTHON_USEDEP}]
	<dev-python/sphinx-tabs-3.5.0[${PYTHON_USEDEP}]
	>=dev-python/sphinx-tabs-1.2.1[${PYTHON_USEDEP}]
	>=dev-python/tabulate-0.8.7[${PYTHON_USEDEP}]
	>=dev-python/typing-extensions-3.7.4.3[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		>=dev-python/coincidence-0.2.0[${PYTHON_USEDEP}]
		>=dev-python/defusedxml-0.7.1[${PYTHON_USEDEP}]
		>=dev-python/flake8-dunder-all-0.0.4[${PYTHON_USEDEP}]
		>=dev-python/hypothesis-5.35.4[${PYTHON_USEDEP}]
		>=dev-python/importlib-metadata-3.6.0[${PYTHON_USEDEP}]
		>=dev-python/pygments-2.11.0[${PYTHON_USEDEP}]
		>=dev-python/pytest-httpserver-0.3.5[${PYTHON_USEDEP}]
		>=dev-python/pytest-timeout-1.4.2[${PYTHON_USEDEP}]
		>=dev-python/sphobjinv-2.0.1[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest

python_prepare_all() {
	distutils-r1_python_prepare_all

	# Avoid requirement on an python3.6 backport
	sed -i -e 's/from pprint36/from pprint/' tests/test_tweaks/test_tabsize.py || die

	# Package expects unnormalized package names which aren't available on Gentoo
	sed -i -e 's/sphinx-prompt/sphinx_prompt/' \
		sphinx_toolbox/installation.py tests/test_output/doc-test/test-root/conf.py || die
}
