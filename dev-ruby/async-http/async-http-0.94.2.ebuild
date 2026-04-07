# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

USE_RUBY="ruby33 ruby34 ruby40"

RUBY_FAKEGEM_RECIPE_TEST="sus"
RUBY_FAKEGEM_EXTRADOC="readme.md"
RUBY_FAKEGEM_GEMSPEC="${PN}.gemspec"

inherit ruby-fakegem

DESCRIPTION="A HTTP client and server library"
HOMEPAGE="https://github.com/socketry/async-http"
SRC_URI="https://github.com/socketry/async-http/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="$(ver_cut 1)"
KEYWORDS="~amd64"

ruby_add_rdepend "
	>=dev-ruby/async-2.10.2
	>=dev-ruby/async-pool-0.11:0
	>=dev-ruby/io-endpoint-0.14:0
	>=dev-ruby/io-stream-0.6:0
	>=dev-ruby/metrics-0.12:0
	>=dev-ruby/protocol-http-0.58:0
	>=dev-ruby/protocol-http1-0.36:0
	>=dev-ruby/protocol-http2-0.22:0
	>=dev-ruby/protocol-url-0.2:0
	>=dev-ruby/traces-0.10:0
"

ruby_add_bdepend "test? (
	dev-ruby/rack-test
	dev-ruby/sus-fixtures-async
	>=dev-ruby/sus-fixtures-async-http-0.8:0
	dev-ruby/sus-fixtures-openssl
)"

PATCHES=(
	"${FILESDIR}"/async-http-0.94.2-ruby4-test.patch
)

all_ruby_prepare() {
	sed -i -E 's/require_relative "(.+)"/require File.expand_path("\1")/g' "${RUBY_FAKEGEM_GEMSPEC}" || die

	# Can lead to hangs due to trying to contact the outside world, especially under load.
	rm test/async/http/client/google.rb  test/async/http/internet.rb || die

	# Remove developer-only test configuration
	rm -f config/sus.rb || die
}

each_ruby_test() {
	# usage of sus-parallel leads to further hangs
	local sus_params=
	case ${TEST_VERBOSE} in
		1|yes|true)
			sus_params+=" --verbose"
			;;
		*)
			;;
	esac
	"${RUBY}" -S sus ${sus_params}
}
