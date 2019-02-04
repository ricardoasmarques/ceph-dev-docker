#!/bin/bash

set -e

cd /ceph/src/pybind/mgr/dashboard/frontend
source /ceph/build/src/pybind/mgr/dashboard/node-env/bin/activate
npm i

npm run build

cd /ceph/build
bin/ceph mgr services

bin/ceph mgr services | jq .dashboard
