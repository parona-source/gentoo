# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_13 )

inherit distutils-r1 pypi

DESCRIPTION="Standard library imghdr redistribution. 'dead battery'."
HOMEPAGE="
	https://github.com/youknowone/python-deadlib/
	https://pypi.org/project/standard-imghdr/
"

LICENSE="PSF-2"
SLOT="0"
KEYWORDS="~amd64"

# Requires python test module
RESTRICT="test"
