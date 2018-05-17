#!/bin/bash

set -e

cd /ceph
find . -name \*.pyc -delete
./install-deps.sh

ARGS="-DWITH_PYTHON3=ON -DWITH_TESTS=OFF -DWITH_CCACHE=ON $ARGS"
NPROC=${NPROC:-$(nproc --ignore=2)}

if [ -d "build" ]; then
    git submodule update --init --recursive
    cd build
    cmake -DBOOST_J=$NPROC $ARGS ..
else
    ./do_cmake.sh $ARGS
    cd build
fi

ccache make -j$NPROC
