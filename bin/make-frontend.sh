#!/bin/bash

set -e

cd /ceph/build/src/pybind/mgr/dashboard
rm -rf node-env

cd /ceph/src/pybind/mgr/dashboard/frontend
rm -rf dist
rm -rf node_modules

cd /ceph/build
make mgr-dashboard-frontend-build
