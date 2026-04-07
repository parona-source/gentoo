# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

USE_RUBY="ruby33 ruby34 ruby40"

RUBY_FAKEGEM_RECIPE_TEST="sus"
RUBY_FAKEGEM_EXTRADOC="readme.md"
RUBY_FAKEGEM_GEMSPEC="${PN}.gemspec"

inherit ruby-fakegem

DESCRIPTION="Test fixtures for running in Async::HTTP"
HOMEPAGE="https://github.com/socketry/sus-fixtures-async-http"
SRC_URI="https://github.com/socketry/sus-fixtures-async-http/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="$(ver_cut 1)"
KEYWORDS="~amd64"

ruby_add_rdepend "
	>=dev-ruby/async-2.36:2
	>=dev-ruby/async-http-0.54:0
	>=dev-ruby/sus-0.31:0
	>=dev-ruby/sus-fixtures-async-0.1:0
"

all_ruby_prepare() {
	sed -i -E 's/require_relative "(.+)"/require File.expand_path("\1")/g' "${RUBY_FAKEGEM_GEMSPEC}" || die

	# Remove developer-only test configuration
	rm -f config/sus.rb || die
}
