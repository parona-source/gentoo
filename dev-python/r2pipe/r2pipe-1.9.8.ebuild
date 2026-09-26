# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{12..15} )

inherit distutils-r1

DESCRIPTION="Pipe interface for radare2"
HOMEPAGE="
	https://github.com/radareorg/radare2-r2pipe
	https://pypi.org/project/r2pipe/
"

# releases aren't tagged on github, but sdist misses test files
COMMIT=4ba63067e3f96ef4bb4a8865d5c27e326325929e

SRC_URI="
	https://github.com/radareorg/radare2-r2pipe/archive/${COMMIT}.tar.gz
		-> radare2-r2pipe-${COMMIT}.gh.tar.gz
"
S="${WORKDIR}/radare2-r2pipe-${COMMIT}/python"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-util/radare2
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest
