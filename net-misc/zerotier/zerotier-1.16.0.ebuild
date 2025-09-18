# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
"

declare -A GIT_CRATES=(
        [jwt]='https://github.com/glimberg/rust-jwt;61a9291fdeec747c6edf14f4fa0caf235136c168;rust-jwt-%commit%'
        [rustfsm]='https://github.com/temporalio/sdk-core;4614dcb8f4ffd2cb244eb0a19d7485c896e3459e;sdk-core-%commit%/fsm'
        [rustfsm_procmacro]='https://github.com/temporalio/sdk-core;4614dcb8f4ffd2cb244eb0a19d7485c896e3459e;sdk-core-%commit%/fsm/rustfsm_procmacro'
        [rustfsm_trait]='https://github.com/temporalio/sdk-core;4614dcb8f4ffd2cb244eb0a19d7485c896e3459e;sdk-core-%commit%/fsm/rustfsm_trait'
        [temporal-client]='https://github.com/temporalio/sdk-core;4614dcb8f4ffd2cb244eb0a19d7485c896e3459e;sdk-core-%commit%/client'
        [temporal-sdk-core-api]='https://github.com/temporalio/sdk-core;4614dcb8f4ffd2cb244eb0a19d7485c896e3459e;sdk-core-%commit%/core-api'
        [temporal-sdk-core-protos]='https://github.com/temporalio/sdk-core;4614dcb8f4ffd2cb244eb0a19d7485c896e3459e;sdk-core-%commit%/sdk-core-protos'
        [temporal-sdk-core]='https://github.com/temporalio/sdk-core;4614dcb8f4ffd2cb244eb0a19d7485c896e3459e;sdk-core-%commit%/core'
        [temporal-sdk]='https://github.com/temporalio/sdk-core;4614dcb8f4ffd2cb244eb0a19d7485c896e3459e;sdk-core-%commit%/sdk'
)

CARGO_OPTIONAL=1
RUST_MIN_VER="1.88"
RUST_OPTIONAL=1

inherit cargo systemd toolchain-funcs

DESCRIPTION="A software-based managed Ethernet switch for planet Earth"
HOMEPAGE="https://www.zerotier.com/"
SRC_URI="
	https://github.com/zerotier/ZeroTierOne/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz
	controller? ( ${CARGO_CRATE_URIS} )
	sso? ( ${CARGO_CRATE_URIS} )
"
if [[ ${PKGBUMPING} != ${PVR} ]]; then
	SRC_URI+="
		controller? (
			https://gitlab.com/api/v4/projects/32909921/packages/generic/${PN}/${PV}/${P}-crates.tar.xz
		)
		sso? (
			https://gitlab.com/api/v4/projects/32909921/packages/generic/${PN}/${PV}/${P}-crates.tar.xz
		)
	"
fi
S="${WORKDIR}"/ZeroTierOne-${PV}

LICENSE="MPL controller? ( ZeroTier )"
# Dependent crate licenses
LICENSE+=" controller? ( 0BSD Apache-2.0 BSD ISC MIT MPL-2.0 Unicode-3.0 ZLIB )"
LICENSE+=" sso? ( 0BSD Apache-2.0 BSD ISC MIT MPL-2.0 Unicode-3.0 ZLIB )"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~riscv ~x86"
IUSE="controller cpu_flags_arm_neon debug sso"

# https://github.com/zerotier/ZeroTierOne/pull/2453
# >=miniupnpnc-2.2.8: https://gitlab.archlinux.org/archlinux/packaging/packages/zerotier-one/-/commit/1d040aee9a4cfecdcc747cb42f92a1420a42a3f4
RDEPEND="
	dev-libs/openssl:=
	dev-cpp/cpp-httplib
	net-libs/libnatpmp
	>=net-libs/miniupnpc-2.2.8:=
	controller? (
		dev-cpp/opentelemetry-cpp[grpc(-),otlp(-),prometheus]
		dev-cpp/redis-plus-plus
		dev-libs/libpqxx
	)
"
DEPEND="
	${RDEPEND}
	dev-cpp/nlohmann_json
"
BDEPEND="
	virtual/pkgconfig
	controller? ( ${RUST_DEPEND} )
	sso? ( ${RUST_DEPEND} )
"

PATCHES=(
	"${FILESDIR}"/${PN}-1.10.1-add-armv7a-support.patch
	"${FILESDIR}"/${PN}-1.16.0-miniupnpc-2.2.8.patch
)

DOCS=( README.md )

pkg_setup() {
	if use controller || use sso ; then
		rust_pkg_setup
	fi
}

src_unpack() {
	if use controller || use sso ; then
		cargo_src_unpack
	else
		default
	fi
}

src_prepare() {
	default

	# Remove vendored code to avoid mixing vendored and system headers,
	# otherwise it will hide api breaks at build time such as:
	# https://github.com/zerotier/ZeroTierOne/issues/2332
	rm -r ext/{miniupnpc,libnatpmp,nlohmann} || die
	rm -r ext/opentelemetry-cpp-* || die
	rm -r ext/hiredis-* || die
	rm -r ext/redis-plus-plus-* || die
	rm -r ext/libpqxx-* || die
	#rm -r ext/inja # header only dependency that could be packaged
	# rm -r ext/http-parser || die # https://github.com/zerotier/ZeroTierOne/issues/355#issuecomment-232086084
	rm -r ext/cpp-httplib || die

	sed -e 's|#include <cpp-httplib/httplib.h>|#include <httplib.h>|' \
		-i service/OneService.cpp nonfree/controller/EmbeddedNetworkController.hpp || die

	sed -e 's|#include <redis++/redis++.h>|#include <sw/redis++/redis++.h>|' \
		-i nonfree/controller/CV1.hpp nonfree/controller/CV2.hpp || die

	sed -e '/LDLIBS/ s|ext/\S*/lib\S*.a||g' \
		-i make-linux.mk || die

	# Remove man page compression and install, we'll handle it with ebuild functions
	sed -e '/install:/,/^$/ { /man[0-9]/d }' \
		-i make-linux.mk || die
}

src_configure() {
	tc-export CXX CC

	INCLUDES="-Irustybits/target -isystem ext -Iext/prometheus-cpp-lite-1.0/core/include -Iext-prometheus-cpp-lite-1.0/3rdparty/http-client-lite/include -Iext/prometheus-cpp-lite-1.0/simpleapi/include"
	LDLIBS=""

	LDLIBS+=" -lcpp-httplib"

	if use controller; then
		INCLUDES+=" $($(tc-getPKG_CONFIG) --cflags redis++)"
		LDLIBS+=" $($(tc-getPKG_CONFIG) --libs redis++)"
	fi

	# Opentelemetry doesn't have pkgconfig files for all needed libraries
	#LDLIBS+=" -lopentelemetry_exporter_in_memory_metric -lopentelemetry_exporter_in_memory -lopentelemetry_exporter_ostream_logs -lopentelemetry_exporter_ostream_metrics -lopentelemetry_exporter_ostream_span -lopentelemetry_exporter_otlp_grpc  -lopentelemetry_exporter_otlp_grpc_client -lopentelemetry_exporter_otlp_grpc_log -lopentelemetry_exporter_otlp_grpc_metrics -lopentelemetry_otlp_recordable -lopentelemetry_common -lopentelemetry_trace -lopentelemetry_common -lopentelemetry_resources -lopentelemetry_logs -lopentelemetry_metrics -lopentelemetry_proto -lopentelemetry_proto_grpc -lopentelemetry_version -lprotobuf -lgrpc++"

	myemakeargs=(
		CC="${CC}"
		CXX="${CXX}"
		STRIP=:

		INCLUDES="${INCLUDES}"
		LDLIBS="${LDLIBS}"

		ZT_DISABLE_NEON="$(usex !cpu_flags_arm_neon 1 0)"

		# Debug doesnt do more than add preprocessor arguments normally,
		# but when rust is used it sets the correct rust directory to link against.
		# It would be added by cargo eclass eitherway, so instead of adding REQUIRED_USE
		# and patching the makefile its just easier to have it.
		ZT_DEBUG="$(usex debug 1 0)"
		ZT_SSO_SUPPORTED="$(usex sso 1 0)"

		# commercial source-available license
		ZT_CONTROLLER="$(usex controller 1 0)"
	)

	if use controller || use sso ; then
		cargo_src_configure
	fi
}

src_compile() {
	if use controller || use sso ; then
		cargo_env emake "${myemakeargs[@]}" one
	else
		emake "${myemakeargs[@]}" one
	fi
}

src_test() {
	emake "${myemakeargs[@]}" selftest
	./zerotier-selftest || die
}

src_install() {
	default

	newinitd "${FILESDIR}/${PN}".init-r1 "${PN}"
	systemd_dounit "${FILESDIR}/${PN}".service

	doman doc/zerotier-{cli.1,idtool.1,one.8}
}
