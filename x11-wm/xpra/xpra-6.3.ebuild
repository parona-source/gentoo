# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )
DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=yes
DISTUTILS_EXT=1
inherit cuda distutils-r1 edo prefix tmpfiles udev xdg

DESCRIPTION="X Persistent Remote Apps (xpra) and Partitioning WM (parti) based on wimpiggy"
HOMEPAGE="https://xpra.org/"

if [[ ${PV} = *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/Xpra-org/xpra.git"
	if [[ ${PV} = 6.9999* ]]; then
		EGIT_BRANCH="v6.x"
	fi
else
	# sdist contains unnecessary files like a full .venv
	SRC_URI="
		https://github.com/Xpra-org/xpra/archive/refs/tags/v${PV}.tar.gz
			-> ${P}.gh.tar.gz
	"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-2 BSD"
SLOT="0"

IUSE="
	+X avif brotli +client +clipboard crypt csc cuda cups dbus doc examples
	gstreamer +gtk3 html ibus jpeg +lz4 lzo mdns minimal oauth opengl openh264
	pinentry pulseaudio qrcode +server sound spng systemd test +trayicon
	udev +vpx webcam webp x264 xdg xinerama video_cards_nvidia wayland
"
REQUIRED_USE="${PYTHON_REQUIRED_USE}
	|| ( client server )
	|| ( x264 vpx )
	client? ( gtk3 )
	clipboard? ( gtk3 )
	cups? ( dbus )
	gtk3? ( X )
	oauth? ( server )
	opengl? ( client )
	test? ( client clipboard crypt dbus gstreamer html server sound xdg webp xinerama )
	video_cards_nvidia? ( cuda )
"
RESTRICT="!test? ( test )"

# The preference with the xpra's "xfvb" implementations are:
# * x11-drivers/xf86-video-dummy:
#    - full Xorg server
#    - multi-monitor virtualization and DPI emulation
# * weston + xwayland
#    - Doesn't pull in x11-base/xorg-server
#    - more limited multi-monitor and DPI support versus Xdummy
# * Xvfb
#   - no multi-monitor support and limited DPI emulation
#   - https://bugs.gentoo.org/934918 its not great so its safer to just put this behind the minimal use flag
# nvenc? ( amd64? ( media-libs/nv-codec-headers ) )
COMMON_DEPEND="
	$(python_gen_cond_dep '
		dev-python/pygobject:3[${PYTHON_USEDEP}]
		opengl? ( dev-python/pyopengl[${PYTHON_USEDEP}] )
		sound? ( dev-python/gst-python:1.0[${PYTHON_USEDEP}] )
		gtk3? (
			app-accessibility/at-spi2-core[introspection]
			dev-python/pygobject:3[cairo]
			dev-libs/glib:2
			dev-libs/gobject-introspection
			dev-libs/libxml2
			gnome-base/gsettings-desktop-schemas[introspection]
			gnome-base/librsvg[introspection]
			media-libs/harfbuzz[introspection]
			x11-libs/cairo
			x11-libs/gdk-pixbuf[introspection]
			x11-libs/libnotify[introspection]
			x11-libs/pango[introspection]
			net-libs/libproxy[introspection]
		)
	')
	dev-libs/xxhash
	sys-process/procps:=
	x11-libs/libdrm
	avif? ( media-libs/libavif:= )
	brotli? ( app-arch/brotli:= )
	client? (
			x11-libs/gtk+:3[X?,introspection]
	)
	jpeg? ( media-libs/libjpeg-turbo:= )
	lz4? ( app-arch/lz4:= )
	!minimal? ( sys-libs/pam )
	mdns? ( dev-libs/mdns )
	openh264? ( media-libs/openh264:= )
	pulseaudio? (
		media-plugins/gst-plugins-pulse:1.0
		media-plugins/gst-plugins-opus
	)
	qrcode? ( media-gfx/qrencode )
	sound? (
		media-libs/gstreamer:1.0[introspection]
		media-libs/gst-plugins-base:1.0
	)
	spng? ( media-libs/libspng )
	vpx? ( media-libs/libvpx:= )
	wayland? ( dev-libs/wayland )
	webp? ( media-libs/libwebp:= )
	X? (
		x11-apps/xrandr
		x11-libs/libXcomposite
		x11-libs/libXdamage
		x11-libs/libXfixes
		x11-libs/libXrandr
		x11-libs/libXres
		x11-libs/libXtst
		x11-libs/libxkbfile
	)
	x264? ( media-libs/x264:= )
"
RDEPEND="${COMMON_DEPEND}
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		dev-python/netifaces[${PYTHON_USEDEP}]
		dev-python/pillow[jpeg?,webp?,${PYTHON_USEDEP}]
		dbus? ( dev-python/dbus-python[${PYTHON_USEDEP}] )
		crypt? ( dev-python/cryptography[${PYTHON_USEDEP}] )
		cups? ( dev-python/pycups[${PYTHON_USEDEP}] )
		lz4? ( dev-python/lz4[${PYTHON_USEDEP}] )
		lzo? ( >=dev-python/python-lzo-0.7.0[${PYTHON_USEDEP}] )
		oauth? ( dev-python/oauthlib[${PYTHON_USEDEP}] )
		opengl? ( dev-python/pyopengl-accelerate[${PYTHON_USEDEP}] )
		webcam? (
			dev-python/numpy[${PYTHON_USEDEP}]
			dev-python/pyinotify[${PYTHON_USEDEP}]
			media-libs/opencv[${PYTHON_USEDEP},python]
		)
		xdg? ( dev-python/pyxdg[${PYTHON_USEDEP}] )
	')
	acct-group/xpra
	x11-apps/xauth
	x11-apps/xmodmap
	|| (
		$(python_gen_cond_dep '
			dev-python/paramiko[${PYTHON_USEDEP}]
		')
		virtual/openssh
	)
	html? ( www-apps/xpra-html5 )
	ibus? ( app-i18n/ibus )
	pinentry? ( app-crypt/pinentry )
	server? (
		|| (
			x11-drivers/xf86-video-dummy
			wayland? ( dev-libs/weston[headless,xwayland] )
			minimal? ( x11-base/xorg-server[-minimal,xvfb] )
		)
	)
	trayicon? ( dev-libs/libayatana-appindicator )
	udev? ( virtual/udev )
	webcam? ( media-video/v4l2loopback )
	xinerama? ( x11-libs/libfakeXinerama )
"
DEPEND="${COMMON_DEPEND}"
BDEPEND="
	${PYTHON_DEPS}
	$(python_gen_cond_dep '
		>=dev-python/cython-3[${PYTHON_USEDEP}]
	')
	cuda? ( dev-util/nvidia-cuda-toolkit )
	doc? ( virtual/pandoc )
	test? (
		${RDEPEND}
		server? ( x11-base/xorg-server[-minimal,xvfb] )
	)
	virtual/pkgconfig
"

python_prepare_all() {
	# Add more switches
	sed -e 's/SWITCHES = \[\]/SWITCHES = \["wayland", "pulseaudio", "xdg_open", "pam"\]/' \
		-i setup.py || die

	if [[ ${PV} =~ 9999$ ]]; then
		# Hack to get setup.py to install src_info through gpep517
		# Only really useful for live packages as it records vcs info.
		# We'll later add the info manually for non vcs.
		sed -e 's/^if "install" in sys.argv or "build" in sys.argv:/if True:/' \
			-i setup.py || die
	fi

	# Follow gentoo policy with documentation location
	sed -e "/doc_dir =/s:/${PN}/\":/${PF}/html\":" \
		-i setup.py || die
	sed -e "s/(\"doc\", \"xpra\", \"index.html\"),/(\"doc\", \"${PF}\", \"html\", \"index.html\"),/" \
		-i xpra/scripts/config.py || die

	sed -e 's|^#!/usr/bin/bash|#!/usr/bin/env bash|' \
		-e '/^rm -fr $INSTALL_ROOT/d' \
		-e '/^UNITTESTS_DIR=/d' \
		-e '/^INSTALL_ROOT=/d' \
		-e '/^$PYTHON .\/setup.py install/d' \
		-i tests/unittests/run || die

	hprefixify xpra/scripts/config.py

	distutils-r1_python_prepare_all
}

python_configure_all() {
	DISTUTILS_ARGS=(
		--without-amf # Appears to expect a missing pkgconfig file and then fails to find headers correctly
		# "$(use_with amf)"
		"$(use_with avif)"
		"$(use_with brotli)"
		"$(use_with sound audio)"
		"$(use_with client)"
		"$(use_with clipboard)"
		"$(use_with csc csc_cython)"
		--without-csc_libyuv # media-libs/libyuv is packaged but xpra wants the non standard pkgconfig file
		# "$(use_with libyuv csc_libyuv)"
		"$(use_with cuda cuda_rebuild)"
		"$(use_with cuda cuda_kernels)"
		"$(use_with dbus)"
		"$(use_with doc docs)"
		--with-drm
		--without-evdi
		# "$(use_with evdi)" x11-drivers/evdi::guru
		"$(use_with examples example)"
		"$(use_with gstreamer)"
		"$(use_with gstreamer gstreamer_audio)"
		"$(use_with gstreamer gstreamer_video)"
		"$(use_with gtk3)"
		"$(use_with html http)"
		"$(use_with mdns)"
		"$(use_with video_cards_nvidia nvidia)"
		--without-nvdec
		--without-nvenc
		--without-nvfbc
		# "$(use_with nvenc nvdec)" # NVIDIA Video Codec SDK
		# "$(use_with nvenc nvenc)" # NVIDIA Video Codec SDK
		# "$(use_with nvenc nvfbc)" # NVIDIA Capture SDK
		"$(use_with opengl)"
		"$(use_with openh264)"
		"$(use_with cups printing)"
		--without-pandoc_lua
		"$(use_with pulseaudio)"
		"$(use_with qrcode qrencode)"
		--without-quic
		# "$(use_with quic)" # https://github.com/aiortc/aioquic
		"$(use_with systemd sd_listen)"
		"$(use_with server)"
		"$(use_with systemd service)"
		"$(use_with server shadow)"
		"$(use_with vpx)"
		"$(use_with wayland)"
		"$(use_with webcam)"
		"$(use_with webp)"
		"$(use_with X x11)"
		"$(use_with X Xdummy)"

		"$(use_with !minimal pam)"
		"$(use_with !minimal xdg_open)"

		"$(use_with test tests)"
		--without-debug # Respect user cflags instead
		--without-strict # adds -Werror
		--with-PIC
		# --with-verbose
		# --with-warn
		# --with-cythonize_more

		--pkg-config-path="${S}/fs/lib/pkgconfig"
	)

	if use server; then
		DISTUTILS_ARGS+=(
			"$(use_with jpeg jpeg_encoder)"
			"$(use_with vpx vpx_encoder)"
			"$(use_with openh264 openh264_encoder)"
			"$(use_with cuda nvjpeg_encoder)"
			"$(use_with avif avif_encoder)"
			"$(use_with webp webp_encoder)"
			"$(use_with spng spng_encoder)"
		)
	else
		DISTUTILS_ARGS+=(
			--without-jpeg_encoder
			--without-vpx_encoder
			--without-openh264_encoder
			--without-nvjpeg_encoder
			--without-avif_encoder
			--without-webp_encoder
			--without-spng_encoder
		)
	fi

	if use client || use gtk3; then
		DISTUTILS_ARGS+=(
			"$(use_with vpx vpx_decoder)"
			"$(use_with openh264 openh264_decoder)"
			"$(use_with cuda nvjpeg_decoder)"
			"$(use_with jpeg jpeg_decoder)"
			"$(use_with avif avif_decoder)"
			"$(use_with webp webp_decoder)"
			"$(use_with spng spng_decoder)"
		)
	else
		DISTUTILS_ARGS+=(
			--without-jpeg_decoder
			--without-vpx_decoder
			--without-openh264_decoder
			--without-nvjpeg_decoder
			--without-avif_decoder
			--without-webp_decoder
			--without-spng_decoder
		)
	fi

	DISTUTILS_ARGS+=(
		# Arguments from user
		"${MYDISTUTILS_ARGS[@]}"
	)

	export XPRA_SOCKET_DIRS="${EPREFIX}/var/run/xpra"
}

python_compile() {
	if use cuda; then
		export NVCC_PREPEND_FLAGS="-ccbin $(cuda_gccdir)/g++"
	fi

	distutils-r1_python_compile

	if ! [[ ${PV} =~ 9999$ ]]; then
		# Do this earlier so that tests have the file
		cat <<-EOF > "${BUILD_DIR}/install/$(python_get_sitedir)/xpra/src_info.py"
		BRANCH = 'unknown'
		COMMIT = 'unknown'
		LOCAL_MODIFICATIONS = 0
		REVISION = 'unknown'
		EOF
	fi
}

python_test() {
	einfo "${BUILD_DIR}/install/$(python_get_sitedir)"

	use cuda && cuda_add_sandbox -w
	addwrite /dev/dri/renderD128

	addpredict /dev/dri/card0
	addpredict /dev/fuse
	addpredict /dev/tty0
	addpredict /dev/vga_arbiter
	addpredict /proc/mtrr
	addpredict /var/run/utmp

	addpredict "$(python_get_sitedir)"

	if [[ -d "/sys/devices/virtual/video4linux" ]]; then
		local devices
		readarray -t devices <<<"$(find /sys/devices/virtual/video4linux -mindepth 1 -maxdepth 1 -type d -name 'video*' )"
		for device in "${devices[@]}"; do
			addwrite "/dev/$(basename "${device}" || die )"
		done
	fi

	xdg_environment_reset

	export XAUTHORITY=${T}/.Xauthority
	touch "${XAUTHORITY}" || die

	local -x XPRA_TEST_COVERAGE=0 INSTALL_ROOT="${BUILD_DIR}/install" UNITTESTS_DIR="${S}/tests/unittests"

	local -a SKIP_FAIL=(
		# parse_vt_settings: Cannot open /dev/tty0 (Permission denied)
		unit.server.mixins.startdesktop_option_test
		unit.server.mixins.start_option_test
		# Copied from upstream ci
		unit.client.splash_test
	)
	local -a SKIP_SLOW=(
		# Copied from upstream ci
		unit.client.x11_client_test
		unit.server.server_sockets_test
		unit.server.subsystem.startdesktop_option_test
		unit.x11.x11_server_test
		unit.server.server_auth_test
		unit.server.shadow_server_test
		unit.server.subsystem.start_option_test
		unit.server.subsystem.shadow_option_test
	)

	edo tests/unittests/run ${SKIP_FAIL[@]/#/--skip-fail } ${SKIP_SLOW[@]/#/--skip-slow }

	# remove test file
	rm -vrf "${BUILD_DIR}/install/usr/share/xpra/www"
}

python_install_all() {
	distutils-r1_python_install_all

	mv -T "${ED}"/usr/etc/ "${ED}"/etc/ || die

	sed -e "s#/.*data/etc#/etc#g" \
		-i "${ED}/etc/xpra/conf.d/"* || die

	# For the manually added src_info.py
	[[ ${PV} =~ 9999$ ]] || python_optimize

	# Move udev dir to the right place if necessary.
	if use udev; then
		local dir
		dir=$(get_udevdir)
		if [[ ! ${ED}/usr/lib/udev -ef ${ED}${dir} ]]; then
			dodir "${dir%/*}"
			mv -vnT "${ED}"/usr/lib/udev "${ED}${dir}" || die
		fi
	else
		rm -vr "${ED}"/usr/lib/udev || die
		rm -v "${ED}"/usr/libexec/xpra/xpra_udev_product_version || die
	fi
}

pkg_postinst() {
	tmpfiles_process xpra.conf
	xdg_pkg_postinst
	use udev && udev_reload
}

pkg_postrm() {
	xdg_pkg_postinst
	use udev && udev_reload
}
