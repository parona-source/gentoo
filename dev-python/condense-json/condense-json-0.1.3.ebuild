# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="Python function for condensing JSON using replacement strings"
HOMEPAGE="
	https://github.com/simonw/condense-json/
	https://pypi.org/project/condense-json/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest
