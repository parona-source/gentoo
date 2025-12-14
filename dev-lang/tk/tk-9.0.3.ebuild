# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# Please bump with dev-lang/tcl!

inherit autotools dot-a multilib-minimal prefix toolchain-funcs virtualx

MY_P="${PN}${PV/_beta/b}"

DESCRIPTION="Tk Widget Set"
HOMEPAGE="https://www.tcl.tk/"
SRC_URI="https://downloads.sourceforge.net/tcl/${MY_P}-src.tar.gz"

S="${WORKDIR}/${MY_P}"
ECONF_SOURCE="${S}/unix"

LICENSE="tcltk"
SLOT="0/$(ver_cut 1-2)"
KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~loong ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x64-solaris"
IUSE="cups debug truetype aqua xscreensaver"
RESTRICT="!test? ( test )"

RDEPEND="
	!aqua? (
		>=media-libs/fontconfig-2.10.92[${MULTILIB_USEDEP}]
		>=x11-libs/libX11-1.6.2[${MULTILIB_USEDEP}]
		>=x11-libs/libXt-1.1.4[${MULTILIB_USEDEP}]
		cups? ( net-print/cups )
		truetype? (
			media-libs/freetype
			>=x11-libs/libXft-2.3.1-r1[${MULTILIB_USEDEP}]
		)
		xscreensaver? ( >=x11-libs/libXScrnSaver-1.2.2-r1[${MULTILIB_USEDEP}] )
	)
	~dev-lang/tcl-$(ver_cut 1-3):0=[${MULTILIB_USEDEP}]"
DEPEND="${RDEPEND}
	!aqua? ( x11-base/xorg-proto )"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}"/${PN}-8.4.15-aqua.patch
	"${FILESDIR}"/${PN}-9.0.3-test.patch
	"${FILESDIR}"/${PN}-8.6.14-test.patch
)

QA_CONFIG_IMPL_DECL_SKIP=(
	stat64 opendir64 readdir64 rewinddir64 closedir64 # used on AIX
)

DOCS=( changes.md README.md )

src_prepare() {
	find \
		"${S}"/compat/* \
		-delete || die

	default
	eprefixify unix/Makefile.in

	# Make sure we use the right pkg-config, and link against fontconfig
	# (since the code base uses Fc* functions).
	sed \
		-e 's/FT_New_Face/XftFontOpen/g' \
		-e "s:\<pkg-config\>:$(tc-getPKG_CONFIG):" \
		-e 's:xft freetype2:xft freetype2 fontconfig:' \
		-i unix/configure.ac || die

	sed -e 's:-O[2s]\?::g' \
		-i unix/tcl.m4 || die

	pushd ${ECONF_SOURCE} >/dev/null || die
	eautoconf
	popd >/dev/null || die

	multilib_copy_sources
}

multilib_src_configure() {
	lto-guarantee-fat

	if tc-is-cross-compiler ; then
		export ac_cv_func_strtod=yes
		export tcl_cv_strtod_buggy=1
	fi

	local mylibdir=$(get_libdir)

	tc-export CC

	# Build with soname, bug #125971
	export TCL_SHLIB_LD_EXTRAS="-Wl,-soname,libtk$(ver_cut 1-2).so"

	local myconf=(
		--with-tcl="${EPREFIX}/usr/$(get_libdir)"
		$(use_enable aqua)
		$(use_enable truetype xft)
		$(use_enable xscreensaver xss)
		$(use_enable debug symbols)
		$(use_enable cups libcups)
	)

	econf "${myconf[@]}"
}

multilib_src_test() {
	CI=1 virtx emake test || die "Tests failed"
}

multilib_src_install() {
	default
	strip-lto-bytecode

	# fix the tkConfig.sh to eliminate refs to the build directory
	# and drop unnecessary -L inclusion to default system libdir

	sed \
		-e "/^TK_BUILD_LIB_SPEC=/s:-L${S}-\w*\.\w* ::g" \
		-e "/^TK_LIB_SPEC=/s:-L${EPREFIX}/usr/$(get_libdir) *::g" \
		-e "/^TK_SRC_DIR=/s:${SPARENT}:${EPREFIX}/usr/$(get_libdir)/tk$(ver_cut 1-2)/include:g" \
		-e "/^TK_BUILD_STUB_LIB_SPEC=/s:-L${S}-\w*\.\w* *::g" \
		-e "/^TK_STUB_LIB_SPEC=/s:-L${EPREFIX}/usr/$(get_libdir) *::g" \
		-e "/^TK_BUILD_STUB_LIB_PATH=/s:${S}-\w*\.\w*:${EPREFIX}/usr/$(get_libdir):g" \
		-e "/^TK_LIB_FILE=/s:'libtk$(ver_cut 1-2)..TK_DBGX..so':\"libk$(ver_cut 1-2)\$\{TK_DBGX\}.so\":g" \
		-i "${ED}"/usr/$(get_libdir)/tkConfig.sh || die
	if use prefix && [[ ${CHOST} != *-darwin* ]] ; then
		sed \
			-e "/^TK_CC_SEARCH_FLAGS=/s|'$|:${EPREFIX}/usr/$(get_libdir)'|g" \
			-e "/^TK_LD_SEARCH_FLAGS=/s|'$|:${EPREFIX}/usr/$(get_libdir)'|" \
			-i "${ED}"/usr/$(get_libdir)/tkConfig.sh || die
	fi

	# install private headers
	#insinto /usr/$(get_libdir)/tk$(ver_cut 1-2)/include/unix
	#doins "${S}"/*.h
	#insinto /usr/$(get_libdir)/tk$(ver_cut 1-2)/include/generic
	#doins "${SPARENT}"/generic/*.h
	#rm -f "${ED}"/usr/$(get_libdir)/tk$(ver_cut 1-2)/include/generic/{tk,tkDecls,tkPlatDecls}.h || die

	# install symlink for libraries
	#dosym libtk$(ver_cut 1-2)$(get_libname) /usr/$(get_libdir)/libtk$(get_libname)
	#dosym libtkstub$(ver_cut 1-2).a /usr/$(get_libdir)/libtkstub.a
}

multilib_src_install_all() {
	dosym wish$(ver_cut 1-2) /usr/bin/wish
	einstalldocs
}
