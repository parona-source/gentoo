# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )
inherit meson python-any-r1 shell-completion

DESCRIPTION="unix-like reverse engineering framework and commandline tools"
HOMEPAGE="https://www.radare.org"

# https://github.com/radareorg/radare2/blob/master/DEVELOPERS.md#regression-testing
TESTBINS_COMMIT=a2a92dc41a06aff40e24cd6a44d372587f01747c

SRC_URI="
	mirror+https://github.com/radareorg/radare2/releases/download/6.2.2/radare2-6.2.2.tar.xz
	test? (
		https://github.com/radareorg/radare2-testbins/archive/${TESTBINS_COMMIT}.tar.gz
			-> radare2-testbins-${TESTBINS_COMMIT}.tar.gz
	)
"

LICENSE="GPL-2"
# sdb
LICENSE+=" MIT"
# quickjs
LICENSE+=" MIT"

SLOT="0/${PV}" # soname set to full version
KEYWORDS="~amd64 ~arm64 ~x86"

IUSE="libuv ssl test"
# Need to audit licenses of the binaries used for testing
RESTRICT="mirror !test? ( test )"

RDEPEND="
	app-arch/lz4:=
	>=dev-libs/capstone-4.0.0:=
	dev-libs/libzip:=
	dev-libs/xxhash
	sys-apps/file
	dev-libs/zydis:=
	virtual/zlib:=
	libuv? ( >=dev-libs/libuv-1.0.0:= )
	ssl? ( dev-libs/openssl:0= )
"
DEPEND="${RDEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	virtual/pkgconfig
"

src_prepare() {
	default

	sed -e "/libdir/ s/lib$/$(get_libdir)/" -i libr/libr.pc.acr || die

	if use test; then
		cp -r "${WORKDIR}/radare2-testbins-${TESTBINS_COMMIT}" "${S}/test/bins" || die
		cp -r "${WORKDIR}/radare2-testbins-${TESTBINS_COMMIT}" "${S}" || die
	fi

	# Fix hardcoded docdir for fortunes
	sed -e "/^#define R2_FORTUNES/s/radare2/${PF}/" \
		-i libr/include/r_userconf.h.acr || die
}

src_configure() {
	local emesonargs=(
		-Dcli=enabled
		$(meson_use libuv use_libuv)
		#$(meson_use squashfs use_libsqsh) # not packaged https://codeberg.org/Gottox/sqsh-tools
		$(meson_use ssl use_ssl)
		$(meson_use test enable_tests)

		# system libs
		-Duse_sys_capstone=true
		-Duse_sys_lz4=true
		-Duse_sys_magic=true
		-Duse_sys_openssl=true
		-Duse_sys_xxhash=true
		-Duse_sys_zip=true
		-Duse_sys_zlib=true
		-Duse_sys_zydis=true
	)
	meson_src_configure
}

src_test() {
	# Homebrew test skips for meson
	local -a tests=( $(meson test --list -C "${BUILD_DIR}") )

	local -a skip_tests=(
		# New failing test https://github.com/radareorg/radare2/commit/522635811f5f8200ce8ce42f3c9f1eade0ff4a7d
		# test_r_core_anal_fcn_variadic_marker_requires_unclobbered_al ERR
		# [XX] Fail at line 286: an unclobbered test of al remains a variadic marker: expected true, got false
		# ERROR: at line 1: Cannot find ) in function definition
		radare2:anal_function
	)

	for test_index in ${!tests[@]}; do
		if [[ ${skip_tests[@]} =~ ${tests[${test_index}]} ]]; then
			unset tests[${test_index}]
		fi
	done

	local -x PATH="${BUILD_DIR}/binr/radare2:${PATH}"
	meson_src_test "${tests[@]}"
}

src_install() {
	meson_src_install

	newbashcomp doc/bash_autocompletion.sh "${PN}"
	bashcomp_alias "${PN}" rafind2 r2 rabin2 rasm2 radiff2

	dozshcomp doc/zsh/_*

	# These are not really docs. radare assumes
	# uncompressed files: bug #761250
	docompress -x /usr/share/doc/${PF}/fortunes.{creepy,fun,nsfw,tips}

	# Create plugins directory although it's currently unsupported by radare2
	keepdir "/usr/$(get_libdir)/radare2/${PV}"
}
