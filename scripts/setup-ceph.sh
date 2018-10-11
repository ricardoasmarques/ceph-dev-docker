#!/bin/bash

set -e

# Make sure all packages are up to date
zypper ref
zypper update -y

# Install all requirements to run tests
cdsd
pip2 install --ignore-installed -r requirements.txt
pip3 install --ignore-installed -r requirements.txt

cd /ceph
find . -name \*.pyc -delete
./install-deps.sh

# SSO dependencies
# (install-deps.sh has to be run before)
pip3 install python3-saml
pip2 install python-saml


ARGS="-DWITH_PYTHON3=ON -DWITH_PYTHON2=OFF -DMGR_PYTHON_VERSION=3 -DWITH_TESTS=ON -DWITH_CCACHE=ON $ARGS"
NPROC=${NPROC:-$(nproc --ignore=2)}

if [ "$MIMIC" == "true" ]; then
    rm /usr/bin/gcc
    rm /usr/bin/g++

    ln -s /usr/bin/gcc-7 /usr/bin/gcc
    ln -s /usr/bin/g++-7 /usr/bin/g++
fi

if [ -d "build" ]; then
    git submodule update -f --recursive --remote
    git submodule update -f --init --recursive
    cd build
    cmake -DBOOST_J=$NPROC $ARGS ..
else
    ./do_cmake.sh $ARGS
    cd build
fi

ccache make -j$NPROC
