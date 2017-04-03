# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id: 1dd4a0d0ab8d2618c6c8aa8214d27d98b73ee831 $

EAPI=5
USE_RUBY="ruby21"

inherit ruby-fakegem

RUBY_FAKEGEM_EXTRAINSTALL="app config db script spec"

DESCRIPTION="The database layer for Metasploit"
HOMEPAGE="https://github.com/rapid7/metasploit_data_models"
SRC_URI="mirror://rubygems/${P}.gem"

LICENSE="BSD"
SLOT="${PV}"
KEYWORDS="~amd64 ~arm"
RESTRICT=test
#IUSE="development test"
IUSE=""

RDEPEND="${RDEPEND} !dev-ruby/metasploit_data_models:0"

ruby_add_rdepend "
		>=dev-ruby/activerecord-4.2.8:4.2[postgres]
		>=dev-ruby/activesupport-4.2.8:4.2
		dev-ruby/pg
		dev-ruby/postgres_ext:3
		>=dev-ruby/railties-4.2.6:4.2
		>=dev-ruby/recog-2.0.0:*
		dev-ruby/arel-helpers
		>=dev-ruby/metasploit-concern-2.0.3
		>=dev-ruby/metasploit-model-2.0.3
		<dev-ruby/thor-2.0"

ruby_add_bdepend "dev-ruby/bundler"

all_ruby_prepare() {
	[ -f Gemfile.lock ] && rm Gemfile.lock
	#if ! use development; then
		sed -i -e "/^group :development do/,/^end$/d" Gemfile || die
		sed -i -e "/s.add_development_dependency/d" "${PN}".gemspec || die
	#fi
	#if ! use test; then
		sed -i -e "/^group :test do/,/^end$/d" Gemfile || die
	#fi
	#if ! use test && ! use development; then
		sed -i -e "/^group :development, :test do/,/^end$/d" Gemfile || die
	#fi
}

each_ruby_prepare() {
	if [ -f Gemfile ]
	then
		BUNDLE_GEMFILE=Gemfile ${RUBY} -S bundle install --local || die
		BUNDLE_GEMFILE=Gemfile ${RUBY} -S bundle check || die
	fi
}

all_ruby_install() {
	ruby_fakegem_binwrapper mdm_console mdm_console-${SLOT}
}