#!/bin/bash

set -e
set -x
dpkg-reconfigure debconf --frontend=noninteractive
cat <<-EOF > /etc/apt/apt.conf.d/90-forceyes
APT::Get::Assume-Yes "true";
APT::Get::force-yes "true";
EOF
apt-get update
apt-get install git devscripts cmake
git clone https://github.com/bareos/bareos
cd bareos
git checkout bareos-19.2
cd core
mk-build-deps -i
dch -v "$(cmake -P ../get_version.cmake | awk '{ print $2 }')" --create "latest 19.2 build" --package bareos
cmake -P ../write_version_files.cmake
debuild -b
