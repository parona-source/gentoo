# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake flag-o-matic

DESCRIPTION="MPEG-5 LCEVC Decoder"
HOMEPAGE="https://github.com/v-novaltd/LCEVCdec"
SRC_URI="
	https://github.com/v-novaltd/LCEVCdec/archive/refs/tags/${PV}.tar.gz
		-> ${P}.tar.gz
"
S="${WORKDIR}/LCEVCdec-${PV}"

LICENSE="BSD"
SLOT="0/$(ver_cut 1)"
KEYWORDS="~amd64"

IUSE="test"
RESTRICT="!test? ( test )"

DEPEND="
	test? (
		dev-cpp/cli11
		dev-cpp/gtest
		dev-cpp/range-v3
		dev-libs/libfmt
		dev-libs/xxhash
	)
"
BDEPEND="
	virtual/pkgconfig
"

PATCHES=(
	"${FILESDIR}"/lcevcdec-4.0.4-test.patch
	"${FILESDIR}"/lcevcdec-4.0.4-nogit.patch
)

src_configure() {
	# lto-type-mismatch
	filter-lto

	# https://github.com/v-novaltd/LCEVCdec/blob/main/docs/building.md
	local mycmakeargs=(
		-DVN_SDK_SAMPLE_SOURCE=OFF # samples
		-DVN_SDK_API_LAYER=ON
		-DVN_SDK_EXECUTABLES=OFF # samples
		-DVN_SDK_UNIT_TESTS=$(usex test)
		-DVN_SDK_JSON_CONFIG=OFF # Required for samples
		-DVN_SDK_PIPELINE_CPU=ON # recommended
		-DVN_SDK_PIPELINE_LEGACY=OFF # deprecated
		-DVN_SDK_PIPELINE_VULKAN=OFF # experimental
		-DVN_SDK_DOCS=OFF

		# Automagic SSE/AVX2/NEON.
		# Currently bits are only built if support detected on build machine,
		# but there is also runtime detection...?
		-DVN_SDK_SIMD=OFF

		-DVN_SDK_LTO=OFF # does nothing special over -flto
		-DVN_SDK_COVERAGE=OFF # not applicable downstream
		-DVN_SDK_WARNINGS_FAIL=OFF # -Werror
		-DVN_SDK_BUILD_DETAILS=OFF
		-DVN_SDK_SYSTEM_INSTALL=ON
	)
	cmake_src_configure
}

src_test() {
	local CMAKE_SKIP_TESTS=(
		# Git LFS files not included in archive
		lcevc_dec_enhancement_test_unit
		lcevc_dec_test_unit
		lcevc_dec_utility_test_unit
		lcevc_dec_pixel_processing_test_unit
	)
	cmake_src_test
}
