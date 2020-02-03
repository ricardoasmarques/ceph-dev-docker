#!/bin/bash

set -e

find /ceph/build/ -name "mgr.*.log" -type f -delete

cd /ceph/build
RGW=1 ../src/vstart.sh -d -n -x

chmod +r /ceph/build/keyring

./bin/ceph config set mgr mgr/dashboard/log_level info
./bin/ceph config set mgr mgr/dashboard/log_to_file true

# Temporary fix for `stray hosts/services` issue of `orchestrator_cli`
./bin/ceph config set mgr mgr/cephadm/warn_on_stray_hosts false && \
    ceph config set mgr mgr/cephadm/warn_on_stray_services false && \
    ceph mgr module enable cephadm

setup-proxy.sh
create-dashboard-rgw-user.sh
