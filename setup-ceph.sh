#!/bin/bash

set -e

cd /ceph
./install-deps.sh
./do_cmake.sh $@
cd /ceph/build
make -j$(nproc)

pip install -r /ceph/src/pybind/mgr/dashboard_v2/requirements.txt
