#!/bin/bash

set -e

cd /ceph
find . -name \*.pyc -delete
./install-deps.sh

export SOURCE_DATE_EPOCH=0
ARGS="-DENABLE_GIT_VERSION=OFF -DWITH_PYTHON3=ON -DWITH_PYTHON2=OFF -DMGR_PYTHON_VERSION=3 -DWITH_TESTS=ON -DWITH_CCACHE=ON $ARGS"
NPROC=${NPROC:-$(nproc --ignore=2)}

if [ "$MIMIC" == "true" ]; then
    rm /usr/bin/gcc
    rm /usr/bin/g++

    ln -s /usr/bin/gcc-7 /usr/bin/gcc
    ln -s /usr/bin/g++-7 /usr/bin/g++
fi

if [ -d "build" ]; then
    git submodule update --init --recursive
    cd build
    cmake -DBOOST_J=$NPROC $ARGS ..
else
    ./do_cmake.sh $ARGS
    cd build
fi

ccache make -j$NPROC

# SSO dependencies
zypper -n install libxmlsec1-1 libxmlsec1-nss1 libxmlsec1-openssl1 xmlsec1-devel xmlsec1-openssl-devel
pip install python3-saml
pip2 install python-saml
