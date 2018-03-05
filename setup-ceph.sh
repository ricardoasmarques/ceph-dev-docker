#!/bin/bash

set -e

cd /ceph
./install-deps.sh

ARGS="-DWITH_PYTHON3=ON -DWITH_TESTS=OFF -DWITH_CCACHE=ON $ARGS"

if [ -d "build" ]; then
    git submodule update --init --recursive
    cd build
    NPROC=${NPROC:-$(nproc)}
    cmake -DBOOST_J=$NPROC $ARGS ..
else
    ./do_cmake.sh $ARGS
    cd build
fi

ccache make -j$(nproc)
