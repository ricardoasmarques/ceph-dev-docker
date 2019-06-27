#!/bin/bash

set -e

find /ceph/build/ -name "mgr.*.log" -type f -delete

cd /ceph/build
RGW=1 ../src/vstart.sh -d -n -x

chmod +r /ceph/build/keyring

setup-proxy.sh
create-dashboard-rgw-user.sh
