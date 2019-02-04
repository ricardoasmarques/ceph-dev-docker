#!/bin/bash

set -e

find /ceph/build/out/ -name "mgr.*.log" -type f -delete

cd /ceph/build
./bin/ceph mgr module disable dashboard
sleep 5
./bin/ceph mgr module enable dashboard
