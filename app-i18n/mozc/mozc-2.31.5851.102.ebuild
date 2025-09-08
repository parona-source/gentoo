# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

BAZEL_COMPAT=8
PYTHON_COMPAT=( python3_{11..14} )
inherit bazel desktop dot-a edo elisp-common python-any-r1 savedconfig toolchain-funcs xdg

# commit: Merge "Update BUILD_OSS to 5851"
MOZC_FCITX_HASH="f16444e45bd3c7f7a0af718f4af86ad181b6dd8b"

DESCRIPTION="Mozc - Japanese input method editor."
HOMEPAGE="https://github.com/google/mozc"
SRC_URI="
	!fcitx5? (
		https://github.com/google/mozc/archive/refs/tags/${PV}.tar.gz
			-> ${P}.tar.gz
		${P}-vendor.tar.xz
	)
	fcitx5? (
		https://github.com/fcitx/mozc/archive/${MOZC_FCITX_HASH}.tar.gz
			-> ${PN}-fcitx5-${PV}.tar.gz
		${PN}-fcitx5-${PV}-vendor.tar.xz
	)
"
S="${WORKDIR}/${P}/src"

# Mozc: BSD
# src/data/dictionary_oss: ipadic, public-domain
# src/data/unicode: unicode
# japanese-usage-dictionary: BSD-2
LICENSE="BSD BSD-2 ipadic public-domain unicode"
SLOT="0"
KEYWORDS="~amd64"
IUSE="debug emacs fcitx5 +gui ibus renderer"
REQUIRED_USE="|| ( emacs fcitx5 ibus )"

DEPEND="
	fcitx5? ( app-i18n/fcitx:5 )
	gui? ( dev-qt/qtbase:6[gui,widgets] )
	ibus? (
		app-i18n/ibus
		dev-libs/glib:2
	)
	renderer? ( dev-qt/qtbase:6[gui,widgets] )
"
RDEPEND="${DEPEND}
	emacs? ( app-editors/emacs:* )
"
BDEPEND="
	${PYTHON_DEPS}
	app-arch/unzip
	virtual/pkgconfig
	fcitx5? ( sys-devel/gettext )
"

SITEFILE="50${PN}-gentoo.el"

PATCHES=(
	"${FILESDIR}"/${PN}-2.31.5851.102-fix_path.patch
)

pkg_setup() {
	python-any-r1_pkg_setup
	bazel_pkg_setup
}

src_unpack() {
	if use fcitx5; then
		unpack ${PN}-fcitx5-${PV}.tar.gz
		ln -sfT "${WORKDIR}"/${PN}-${MOZC_FCITX_HASH} "${WORKDIR}"/${P} || die
		unpack ${PN}-fcitx5-${PV}-vendor.tar.xz
	else
		unpack ${P}.tar.gz
		unpack ${P}-vendor.tar.xz
	fi
}

mozc_icons() {
	if use fcitx5 || use gui || use ibus; then
		return 0
	fi
}

src_prepare() {
	default

	# fix paths to preserve compatibility
	sed -e "/LINUX_MOZC_SERVER_DIR/s:=.*:= \"/usr/libexec/mozc\":" \
		-e "/IBUS_MOZC_PATH/s:=.*:= \"/usr/libexec/ibus-engine-mozc\":" \
		-i config.bzl || die

	# respect prefix
	if [[ -n ${EPREFIX} ]]; then
		sed	-e "s@/usr@${EPREFIX}/usr@" -i config.bzl || die
	fi

	# fix pkg-config for fcitx5 / ibus / glib / Qt
	tc-export PKG_CONFIG
	sed -e "s@\"pkg-config\"@\"${PKG_CONFIG}\"@" \
		-i bazel/pkg_config_repository.bzl || die

	# bug #877765
	restore_config mozcdic-ut.txt
	if [[ -f /mozcdic-ut.txt && -s mozcdic-ut.txt ]]; then
		einfo "mozcdic-ut.txt found. Adding to mozc dictionary..."
		cat mozcdic-ut.txt >> "${S}"/data/dictionary_oss/dictionary00.txt || die
	fi

	# custom the target 'package' defined in unix/BUILD.bazel
	if ! mozc_icons; then
		sed -e "\@:icons@d" \
			-i unix/BUILD.bazel || die
	fi

	if ! use emacs; then
		sed -e "\@//unix/emacs:mozc_emacs_helper@d" \
			-e "\@//unix/emacs:mozc.el@d" \
			-i unix/BUILD.bazel || die
	fi

	if ! use gui; then
		sed -e "\@//gui/tool:mozc_tool@d" \
			-i unix/BUILD.bazel || die
	fi

	if ! use ibus; then
		sed -e "\@//unix/ibus:gen_mozc_xml@d" \
			-e "\@//unix/ibus:ibus_mozc@d" \
			-i unix/BUILD.bazel || die
	fi

	if ! use renderer; then
		sed -e "\@//renderer/qt:mozc_renderer@d" \
			-i unix/BUILD.bazel || die
	fi
}

src_configure() {
	# to investigate, but there's lot of static libs
	lto-guarantee-fat

	BAZEL_BUILD_TARGETS=( package )
	BAZEL_BUILD_ARGS=( --config="oss_linux" )

	if use fcitx5; then
		BAZEL_BUILD_TARGETS+=( unix/fcitx5/fcitx5-mozc.so )
		# just to be sure, use_server is enabled by default
		BAZEL_BUILD_ARGS+=( --define server=1 )
	fi

	bazel_src_configure
}

src_compile() {
	bazel_src_compile

	# bazel-bin is a symlink, copy files to avoid problem with symlink then
	cp -R bazel-bin/unix out_linux || die

	use emacs && elisp-compile unix/emacs/*.el
}

src_test() {
	BAZEL_TEST_TARGETS=( /... )
	BAZEL_SKIP_TESTS=(
		-protocol/... # not unix, no testsuite
		$(usev !emacs -unix/emacs/...)
		$(usev !gui -gui/...)
		$(usev !ibus -unix/ibus/...)
		$(usev !renderer -renderer/...)
		$(usev fcitx5 -unix/fcitx/...)
	)
	bazel_src_test
}

src_install() {
	unzip -qo out_linux/mozc.zip -d "${ED}" || die

	# remove mozc.el, in a wrong path
	# already compiled elsewhere and installed then
	if use emacs; then
		rm -r "${ED}"/usr/share/emacs/site-lisp/emacs-mozc || die
		elisp-install ${PN} unix/emacs/*.{el,elc}
		elisp-site-file-install "${FILESDIR}"/${SITEFILE} ${PN}
	fi

	if mozc_icons; then
		# remove tmp with duplicate icons zipped
		rm -r "${ED}"/tmp || die
		if ! use ibus; then
			rm -r "${ED}"/usr/share/ibus-mozc || die
		fi
		if ! use gui; then
			rm -r "${ED}"/usr/share/icons/mozc || die
		fi
	fi

	if use fcitx5; then
		exeinto /usr/$(get_libdir)/fcitx5
		doexe out_linux/fcitx5/fcitx5-mozc.so

		# see scripts/install_fcitx5_data
		insinto /usr/share/fcitx5/addon
		newins unix/fcitx5/mozc-addon.conf mozc.conf

		insinto /usr/share/fcitx5/inputmethod
		doins unix/fcitx5/mozc.conf

		export MOPREFIX="fcitx5-mozc"
		local mo_file
		for mo_file in unix/fcitx5/po/*.po; do
			msgfmt "${mo_file}" -o "${mo_file%.po}.mo" && domo "${mo_file%.po}.mo"  || die
		done

		msgfmt --xml -d unix/fcitx5/po/ \
			--template unix/fcitx5/org.fcitx.Fcitx5.Addon.Mozc.metainfo.xml.in \
			-o unix/fcitx5/org.fcitx.Fcitx5.Addon.Mozc.metainfo.xml || die
		insinto /usr/share/metainfo
		doins unix/fcitx5/org.fcitx.Fcitx5.Addon.Mozc.metainfo.xml

		# see scripts/install_fcitx5_icons
		local orgfcitx5="org.fcitx.Fcitx5.fcitx-mozc"
		newicon -s 128 data/images/product_icon_32bpp-128.png ${orgfcitx5}.png
		newicon -s 128 data/images/product_icon_32bpp-128.png fcitx-mozc.png
		newicon -s 32 data/images/unix/ime_product_icon_opensource-32.png ${orgfcitx5}.png
		newicon -s 32 data/images/unix/ime_product_icon_opensource-32.png fcitx-mozc.png
		for uiimg in ../scripts/icons/ui-*.png; do
			dimg="${uiimg#*ui-}"
			newicon -s 48 "${uiimg}" "${orgfcitx5}-${dimg/_/-}"
			newicon -s 48 "${uiimg}" "fcitx-mozc-${dimg/_/-}"
		done
	fi

	[[ -s mozcdic-ut.txt ]] && save_config mozcdic-ut.txt

	insinto /usr/libexec/mozc/documents
	doins data/installer/credits_en.html
}

pkg_postinst() {
	elog
	elog "ENVIRONMENTAL VARIABLES"
	elog
	elog "MOZC_SERVER_DIRECTORY"
	elog "  Mozc server directory"
	elog "  Value used by default: \"${EPREFIX}/usr/libexec/mozc\""
	elog "MOZC_DOCUMENTS_DIRECTORY"
	elog "  Mozc documents directory"
	elog "  Value used by default: \"${EPREFIX}/usr/libexec/mozc/documents\""
	elog "MOZC_CONFIGURATION_DIRECTORY"
	elog "  Mozc configuration directory"
	elog "  Value used by default: \"~/.mozc\""
	elog
	if use emacs; then
		elog
		elog "USAGE IN EMACS"
		elog
		elog "mozc-mode is minor mode to input Japanese text using Mozc server."
		elog "mozc-mode can be used via LEIM (Library of Emacs Input Method)."
		elog
		elog "In order to use mozc-mode by default, the following settings should be added to"
		elog "Emacs init file (~/.emacs.d/init.el or ~/.emacs):"
		elog
		elog "  (require 'mozc)"
		elog "  (set-language-environment \"Japanese\")"
		elog "  (setq default-input-method \"japanese-mozc\")"
		elog
		elog "With the above settings, typing C-\\ (which is bound to \"toggle-input-method\""
		elog "by default) will enable mozc-mode."
		elog
		elog "Alternatively, at run time, after loading mozc.el, mozc-mode can be activated by"
		elog "calling \"set-input-method\" and entering \"japanese-mozc\"."
		elog

		elisp-site-regen
	fi
	xdg_pkg_postinst
}

pkg_postrm() {
	if use emacs; then
		elisp-site-regen
	fi
	xdg_pkg_postrm
}
