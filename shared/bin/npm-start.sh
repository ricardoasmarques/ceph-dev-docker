#!/bin/bash

set -e

setup-proxy.sh

pushd /ceph/build
make mgr-dashboard-frontend-deps
popd

cd /ceph/src/pybind/mgr/dashboard/frontend
source /ceph/build/src/pybind/mgr/dashboard/node-env/bin/activate
npm start -- --disableHostCheck=true
