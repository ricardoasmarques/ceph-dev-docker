#!/bin/bash

set -e

cd /ceph
./install-deps.sh
./do_cmake.sh $@
cd /ceph/build
make -j$(nproc)

if which pip2; then
    pip2 install -r /ceph/src/pybind/mgr/dashboard_v2/requirements.txt
fi

if which pip3; then
    pip3 install -r /ceph/src/pybind/mgr/dashboard_v2/requirements.txt
fi
