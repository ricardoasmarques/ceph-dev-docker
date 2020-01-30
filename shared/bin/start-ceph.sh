#!/bin/bash

set -e

find /ceph/build/ -name "mgr.*.log" -type f -delete

cd /ceph/build
RGW=1 ../src/vstart.sh -d -n -x

chmod +r /ceph/build/keyring

./bin/ceph config set mgr mgr/dashboard/log_level info
./bin/ceph config set mgr mgr/dashboard/log_to_file true
./bin/ceph config set mgr mgr/dashboard/debug true

setup-proxy.sh
create-dashboard-rgw-user.sh
