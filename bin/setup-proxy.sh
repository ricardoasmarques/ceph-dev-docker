#!/bin/bash

set -e

cd /ceph/build
url=`./bin/ceph mgr services | jq .dashboard`

cd /ceph/src/pybind/mgr/dashboard/frontend
jq '.["/api/"].target'=$url proxy.conf.json.sample > proxy.conf.json
