# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit eutils systemd unpacker user

DESCRIPTION="Plex Media Server is an organizer for your personal media and provides streaming over the web and to devices"
HOMEPAGE="http://plex.tv/"

MY_PN="plexmediaserver"
MAGIC="678-c48ffd2"
MY_PV="${PV}.${MAGIC}"
MY_P="${MY_PN}_${MY_PV}"

SRC_URI="
	x86? (
		https://downloads.plex.tv/plex-media-server/${MY_PV}/${MY_P}_i386.deb
	)
	amd64? (
		https://downloads.plex.tv/plex-media-server/${MY_PV}/${MY_P}_amd64.deb
	)
"

LICENSE="PMS-License"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

DEPEND="
	net-dns/avahi
"
RDEPEND="
	${DEPEND}
"

S="${WORKDIR}"

QA_PREBUILT="*"

pkg_setup() {
	enewgroup plex
	enewuser plex -1 /bin/sh /var/lib/plexmediaserver "plex" --system
}

src_prepare() {
	epatch "${FILESDIR}/start_pms_opt.patch"
}

src_install() {
	#Package contents
	insinto /etc/default
	doins etc/default/plexmediaserver

	dodir /opt/plexmediaserver
	cp -R usr/lib/plexmediaserver/* "${D}"/opt/plexmediaserver/

	dobin usr/sbin/start_pms

	domenu usr/share/applications/plexmediamanager.desktop
	doicon usr/share/pixmaps/plexmediamanager.png

	dodoc usr/share/doc/plexmediaserver/copyright

	#Init files
	doinitd "${FILESDIR}"/plexmediaserver
	systemd_dounit "${FILESDIR}"/plexmediaserver.service

	#Directories
	dodir /var/lib/plexmediaserver
	fowners plex:plex /var/lib/plexmediaserver
	dodir /var/log/pms
	fowners plex:plex /var/log/pms
}

pkg_postinst() {
	einfo "To start Plex Media Server, use the plexmediaserver init script or systemd unit."
	einfo "You can then manage your library and sign in to Plex from \"http://localhost:34200/web\"."
}
