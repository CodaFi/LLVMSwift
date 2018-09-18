#!/bin/bash

export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:"${PKG_CONFIG_PATH}"
wget -O - http://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
apt-add-repository "deb http://apt.llvm.org/trusty/ llvm-toolchain-trusty-6.0
apt-add-repository -y "ppa:ubuntu-toolchain-r/test"
apt-get update
apt-get install -y llvm-6.0
ln -s /usr/bin/llvm-config-6.0 /usr/bin/llvm-config
wget -q -O - https://swift.org/keys/all-keys.asc | gpg --import -
wget https://swift.org/builds/swift-4.1-release/ubuntu1404/swift-4.1-RELEASE/4.1-RELEASE-ubuntu14.04.tar.gz
tar xzf swift-4.1-RELEASE-ubuntu14.04.tar.gz
export PATH=${PWD}/swift-4.1-RELEASE-ubuntu14.04/usr/bin:"${PATH}"
