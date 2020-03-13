#!/bin/bash

set -e

find /ceph/build/ -name "mgr.*.log" -type f -delete

if rpm --quiet --query nfs-ganesha-ceph; then
    export GANESHA=1
fi

cd /ceph/build
RGW=1 ../src/vstart.sh -d -n -x

chmod +r /ceph/build/keyring

if ./bin/ceph config ls | grep -q mgr/dashboard/log_level; then
    ./bin/ceph config set mgr mgr/dashboard/log_level debug
    ./bin/ceph config set mgr mgr/dashboard/log_to_file true
    ./bin/ceph config set mgr mgr/dashboard/debug true
fi

setup-proxy.sh
create-dashboard-rgw-user.sh
