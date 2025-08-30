# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="Cog: A content generator for executing Python snippets in source files"
HOMEPAGE="
	https://github.com/nedbat/cog/
	https://pypi.org/project/cogapp/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
