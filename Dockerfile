from ubuntu:22.04 as build
run apt update && apt upgrade -y && DEBIAN_FRONTEND=noninteractive apt install -y git default-libmysqlclient-dev intel-cmt-cat libxtables-dev debhelper javahelper libatasmart-dev libcap-dev libcurl4-gnutls-dev libdbi0-dev libdpdk-dev libesmtp-dev libganglia1-dev libgcrypt20-dev libglib2.0-dev libgrpc++-dev libgps-dev libhiredis-dev libi2c-dev libldap2-dev liblua5.3-dev liblvm2-dev libmemcached-dev libmicrohttpd-dev libmodbus-dev libmongoc-dev libnotify-dev libopenipmi-dev liboping-dev libow-dev libperl-dev libpq-dev libprotobuf-c-dev libprotobuf-dev librabbitmq-dev librdkafka-dev libriemann-client-dev librrd-dev libtkrzw-dev libupsclient-dev libvirt-dev libxen-dev libxml2-dev libyajl-dev default-jdk protobuf-c-compiler protobuf-compiler protobuf-compiler-grpc python3-dev riemann-c-client flex bison automake autoconf pkg-config libtool build-essential libsnmp-dev devscripts libslurm-dev libslurm-perl libmosquitto-dev libvarnishapi-dev libnetapp-perl libiptc-dev libsigrok-dev libsensors-dev libtokyocabinet-dev && rm -rf /var/lib/apt/lists
run git clone https://github.com/BrandonArp/collectd.git
workdir collectd
run git config --global user.email "admin@admin.com" && git config --global user.name "Admin" && git checkout add_index_rates
run git archive --format=tar -o collectd_5.12.1.orig.tar HEAD
run mkdir debbuild
run mv collectd*.tar debbuild/
workdir debbuild
run rm -rf pkg-debian && git clone https://github.com/BrandonArp/pkg-debian.git
run mv pkg-debian/debian .
run tar --append -f collectd_5.12.1.orig.tar debian
run gzip -f collectd_5.12.1.orig.tar
run mkdir -p /build/collectd-5.12.1
run cp *.tar.gz /build/collectd-5.12.1
run cp *.tar.gz /build/
workdir /build/collectd-5.12.1
run tar -xf *.tar.gz
run mv *.tar.gz ..
run debuild -b -uc -us
run rm /build/collectd-dbg* && rm /build/collectd-dev*

from ubuntu:22.04
#run sed -i "s#main#main contrib non-free#g" /etc/apt/sources.list
run apt update && DEBIAN_FRONTEND=noninteractive apt install -y libcap2 librrd8 libyajl2 libmnl0 libcurl3-gnutls unzip \
	snmp snmp-mibs-downloader libfl2 lsb-base libmosquitto1 && download-mibs && rm -rf /var/lib/apt/lists/*
copy --from=build /build/*.deb /
run dpkg -i *.deb && rm -rf *.deb
run wget https://downloads.dell.com/FOLDER04618816M/1/Dell-OM-MIBS-910_A00.zip && mkdir -p /usr/share/snmp/mibs &&  unzip -j *.zip -d /usr/share/snmp/mibs
run rm -rf /etc/collectd
copy config /etc/collectd
entrypoint ["/usr/sbin/collectd", "-C", "/etc/collectd/collectd.conf", "-f"]
