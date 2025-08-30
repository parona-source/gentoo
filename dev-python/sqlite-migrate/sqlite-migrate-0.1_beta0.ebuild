# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYPI_NO_NORMALIZE=1
DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{11..14} )

inherit distutils-r1 pypi

DESCRIPTION="A simple database migration system for SQLite, based on sqlite-utils"
HOMEPAGE="
	https://pypi.org/project/sqlite-migrate/
"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/sqlite-utils[${PYTHON_USEDEP}]
"
BDEPEND="
	test? (
		dev-python/cogapp[${PYTHON_USEDEP}]
	)
"

EPYTEST_PLUGINS=()
distutils_enable_tests pytest

src_prepare() {
	default

	cat <<-EOF >> pyproject.toml
	[build-system]
	build-backend = "setuptools.build_meta"
	EOF
}
