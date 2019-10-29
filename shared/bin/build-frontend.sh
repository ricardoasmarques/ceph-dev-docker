#!/bin/bash

set -e

cd /ceph/src/pybind/mgr/dashboard/frontend
source /ceph/build/src/pybind/mgr/dashboard/node-env/bin/activate
npm ci

npm run build:en-US

cd /ceph/build
bin/ceph mgr services

bin/ceph mgr services | jq .dashboard
