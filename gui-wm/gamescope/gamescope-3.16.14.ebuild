# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit fcaps meson

MY_PV=$(ver_rs 3 -)
MY_PV="${MY_PV//_/-}"

DESCRIPTION="Efficient micro-compositor for running games"
HOMEPAGE="https://github.com/ValveSoftware/gamescope"
EGIT_SUBMODULES=( src/reshade subprojects/{libliftoff,vkroots,wlroots} )

if [[ ${PV} == "9999" ]]; then
	EGIT_REPO_URI="https://github.com/ValveSoftware/${PN}.git"
	inherit git-r3
else
	RESHADE_COMMIT="696b14cd6006ae9ca174e6164450619ace043283"
	LIBLIFTOFF_COMMIT="0.5.0" # Upstream points at this release.
	VKROOTS_COMMIT="5106d8a0df95de66cc58dc1ea37e69c99afc9540"
	WLROOTS_COMMIT="54e844748029d4874e14d0c086d50092c04c8899"
	SRC_URI="
		https://github.com/ValveSoftware/${PN}/archive/refs/tags/${MY_PV}.tar.gz -> ${P}.tar.gz
		https://gitlab.freedesktop.org/emersion/libliftoff/-/releases/v${LIBLIFTOFF_COMMIT}/downloads/libliftoff-${LIBLIFTOFF_COMMIT}.tar.gz
		https://github.com/Joshua-Ashton/reshade/archive/${RESHADE_COMMIT}.tar.gz -> reshade-${RESHADE_COMMIT}.tar.gz
		https://github.com/Joshua-Ashton/vkroots/archive/${VKROOTS_COMMIT}.tar.gz -> vkroots-${VKROOTS_COMMIT}.tar.gz
		https://github.com/Joshua-Ashton/wlroots/archive/${WLROOTS_COMMIT}.tar.gz -> wlroots-${WLROOTS_COMMIT}.tar.gz
	"
	KEYWORDS="~amd64"
fi

# See wrap files for commits
GLM_COMMIT="0af55ccecd98d4e5a8d1fad7de25ba429d60e863"
STB_COMMIT="5736b15f7ea0ffb08dd38af21067c314d6a3aae9"
SRC_URI+="
	https://github.com/g-truc/glm/archive/${GLM_COMMIT}.tar.gz -> glm-${GLM_COMMIT}.tar.gz
	https://github.com/nothings/stb/archive/${STB_COMMIT}.tar.gz -> stb-${STB_COMMIT}.tar.gz
"

S="${WORKDIR}/${PN}-${MY_PV}"
LICENSE="BSD-2"
SLOT="0"
IUSE="avif libei pipewire +sdl systemd +wsi-layer"

RDEPEND="
	dev-lang/luajit:2=
	>=dev-libs/libinput-1.14.0:=
	>=dev-libs/wayland-1.23
	gui-libs/libdecor
	<media-libs/libdisplay-info-0.3:=
	media-libs/vulkan-loader
	sys-apps/hwdata
	sys-libs/libcap
	>=x11-libs/libdrm-2.4.122
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXcursor
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXi
	x11-libs/libxkbcommon
	x11-libs/libXmu
	x11-libs/libXrender
	x11-libs/libXres
	x11-libs/libXtst
	x11-libs/libXxf86vm
	avif? ( >=media-libs/libavif-1.0.0:= )
	libei? ( dev-libs/libei )
	pipewire? ( >=media-video/pipewire-0.3:= )
	sdl? ( media-libs/libsdl2[video,vulkan] )
	systemd? ( sys-apps/systemd:= )
	wsi-layer? ( x11-libs/libxcb )
"
# For bundled wlroots.
RDEPEND+="
	media-libs/libglvnd
	media-libs/mesa[opengl]
	sys-auth/seatd:=
	virtual/libudev
	x11-base/xwayland
	x11-libs/libxcb:=
	>=x11-libs/pixman-0.42.0
	x11-libs/xcb-util-wm
"
DEPEND="
	${RDEPEND}
	>=dev-libs/wayland-protocols-1.34
	dev-util/vulkan-headers
	dev-util/spirv-headers
	wsi-layer? ( >=media-libs/vkroots-0_p20240430 )
"
BDEPEND="
	dev-util/glslang
	dev-util/wayland-scanner
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}"/gamescope-3.16.14-systemd-without-automagic.patch
)

FILECAPS=(
	cap_sys_nice usr/bin/${PN}
)

src_prepare() {
	default

	if [[ ${PV} != "9999" ]]; then
		# non vcs source cannot be sourced for tags
		sed -i -e "s/^vcs_tag = .*$/vcs_tag = '${PV} (Gentoo)'/" src/meson.build || die

		# ReShade is bundled as a git submodule, but it references an unofficial
		# fork, so we cannot unbundle it. Upstream have requested that we do not
		# unbundle libliftoff, vkroots, or wlroots. Symlink to the extracted sources
		# when not using the git submodules in 9999.
		local dir name commit
		for dir in "${EGIT_SUBMODULES[@]}"; do
			rmdir "${dir}" || die
			name=${dir##*/}
			commit=${name^^}_COMMIT
			ln -snfT "../../${name}-${!commit}" "${dir}" || die
		done
	fi

	mv "${WORKDIR}"/glm-${GLM_COMMIT} "${S}"/subprojects/glm || die
	mv "${S}"/subprojects/packagefiles/glm/* "${S}"/subprojects/glm || die
	mv "${WORKDIR}"/stb-${STB_COMMIT} "${S}"/subprojects/stb || die
	mv "${S}"/subprojects/packagefiles/stb/* "${S}"/subprojects/stb || die

	# SPIRV-Headers is required by ReShade. It is bundled as a git submodule but
	# not wrapped with Meson, so we can symlink to our system-wide headers.
	# For 9999, this submodule is not included.
	mkdir -p thirdparty/SPIRV-Headers/include || die
	ln -snf "${ESYSROOT}"/usr/include/spirv thirdparty/SPIRV-Headers/include/ || die
}

src_configure() {
	# Disabling DRM backend is currently broken.
	# https://github.com/ValveSoftware/gamescope/issues/1347
	local emesonargs=(
		$(meson_feature pipewire)
		-Ddrm_backend=enabled
		$(meson_feature sdl sdl2_backend)
		$(meson_feature avif avif_screenshots)
		$(meson_feature libei input_emulation)
		$(meson_feature systemd)
		$(meson_use wsi-layer enable_gamescope_wsi_layer)
		-Denable_openvr_support=false
		-Dbenchmark=disabled

		-Dwlroots:xcb-errors=disabled
		-Dwlroots:examples=false
		-Dwlroots:renderers=gles2,vulkan
		-Dwlroots:xwayland=enabled
		-Dwlroots:backends=libinput
		-Dwlroots:session=enabled
	)
	meson_src_configure
}

src_install() {
	meson_src_install --skip-subprojects
}
