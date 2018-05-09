#!/bin/bash

set -e

setup-proxy

cd /ceph/src/pybind/mgr/dashboard/frontend
source /ceph/build/src/pybind/mgr/dashboard/node-env/bin/activate
npm i

npm start
