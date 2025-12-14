# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Please bump with dev-lang/tk!

inherit autotools dot-a flag-o-matic multilib-minimal toolchain-funcs

MY_P="${PN}${PV}"

DESCRIPTION="Tool Command Language"
HOMEPAGE="http://www.tcl.tk/"
SRC_URI="https://downloads.sourceforge.net/tcl/${PN}-core${PV}-src.tar.gz"

S="${WORKDIR}/${MY_P}"
ECONF_SOURCE="${S}/unix"

LICENSE="tcltk Spencer-99"
# Third party licences in compat
LICENSE+=" BSD ZLIB"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~loong ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86 ~amd64-linux ~x86-linux ~arm64-macos ~ppc-macos ~x64-macos ~x64-solaris"
IUSE="debug zip"

RDEPEND="
	>=dev-libs/libtommath-1.2.0
	sys-libs/timezone-data
	>=virtual/zlib-1.2.8-r1:=[${MULTILIB_USEDEP}]
"
DEPEND="${RDEPEND}"
BDEPEND="zip? ( app-arch/zip )"

QA_CONFIG_IMPL_DECL_SKIP=(
	stat64 opendir64 rewinddir64 closedir64 # used to test for Large File Support
)

DOCS=( changes.md README.md )

src_prepare() {
	default

	# Drop -Werror
	sed -e "s: -Werror::g" \
		-i unix/dltest/Makefile.in || die

	sed -e 's:-O[2s]\?::g' \
		-i unix/tcl.m4 || die

	pushd ${ECONF_SOURCE} >/dev/null || die
	eautoconf
	popd >/dev/null || die

	multilib_copy_sources
}

multilib_src_configure() {
	lto-guarantee-fat

	tc-export CC

	# workaround stack check issues, bug #280934
	use hppa && append-cflags "-DTCL_NO_STACK_CHECK=1"

	# Build with soname, bug #125971
	export TCL_SHLIB_LD_EXTRAS="-Wl,-soname,libtcl$(ver_cut 1-2).so"

	local myconf=(
		--with-system-libtommath
		$(use_enable debug symbols)
		--includedir="${EPREFIX}/usr/include/tcl$(ver_cut 1-2)"
		$(use_enable zip zipfs)
		#$(use_enable dtrace)
		--disable-dtrace
		--enable-man-symlinks
		--without-tzdata # use system timezone data
	)

	econf "${myconf[@]}"
}

multilib_src_install() {
	default
	strip-lto-bytecode

	# fix the tclConfig.sh to eliminate refs to the build directory
	# and drop unnecessary -L inclusion to default system libdir

	sed -e "/^TCL_BUILD_LIB_SPEC=/s:-L$(pwd) *::g" \
		-e "/^TCL_LIB_SPEC=/s:-L${EPREFIX}/usr/$(get_libdir) *::g" \
		-e "/^TCL_SRC_DIR=/s:${S}:${EPREFIX}/usr/$(get_libdir)/tcl$(ver_cut 1-2)/include:g" \
		-e "/^TCL_BUILD_STUB_LIB_SPEC=/s:-L$(pwd) *::g" \
		-e "/^TCL_STUB_LIB_SPEC=/s:-L${EPREFIX}/usr/$(get_libdir) *::g" \
		-e "/^TCL_BUILD_STUB_LIB_PATH=/s:$(pwd):${EPREFIX}/usr/$(get_libdir):g" \
		-e "/^TCL_LIBW_FILE=/s:'libtcl$(ver_cut 1-2)..TCL_DBGX..so':\"libtcl$(ver_cut 1-2)\$\{TCL_DBGX\}.so\":g" \
		-i "${ED}"/usr/$(get_libdir)/tclConfig.sh || die

	if use prefix && [[ ${CHOST} != *-darwin* ]] ; then
		sed -e "/^TCL_CC_SEARCH_FLAGS=/s|'$|:${EPREFIX}/usr/$(get_libdir)'|g" \
			-e "/^TCL_LD_SEARCH_FLAGS=/s|'$|:${EPREFIX}/usr/$(get_libdir)'|" \
			-i "${ED}"/usr/$(get_libdir)/tclConfig.sh || die
	fi
}

multilib_src_install_all() {
	dosym tclsh$(ver_cut 1-2) /usr/bin/tclsh
	einstalldocs
}
