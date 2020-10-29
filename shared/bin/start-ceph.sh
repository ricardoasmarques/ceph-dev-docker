#!/bin/bash

set -e

find /ceph/build/ -name "mgr.*.log" -type f -delete

if rpm --quiet --query nfs-ganesha-ceph; then
    CEPH_VERSION=$(head -n1 /ceph/src/ceph_release) 
    if [ $CEPH_VERSION -ge 15 ]; then
        export NFS=1
    fi
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
