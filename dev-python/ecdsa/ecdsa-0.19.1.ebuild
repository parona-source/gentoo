# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} pypy3 pypy3_11 )

inherit distutils-r1 pypi

DESCRIPTION="ECDSA cryptographic signature library in pure Python"
HOMEPAGE="
	https://github.com/tlsfuzzer/python-ecdsa/
	https://pypi.org/project/ecdsa/
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm arm64 ~hppa ~mips ppc ppc64 ~riscv sparc x86 ~ppc-macos ~x64-macos"

RDEPEND="
	$(python_gen_cond_dep '
		dev-python/gmpy2[${PYTHON_USEDEP}]
	' 'python*')
	dev-python/six[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		dev-python/hypothesis[${PYTHON_USEDEP}]
	)
"

distutils_enable_tests pytest
