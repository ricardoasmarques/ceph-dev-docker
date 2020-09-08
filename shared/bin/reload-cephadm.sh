#!/bin/bash

set -e

cd /ceph/build
./bin/ceph mgr module disable cephadm
sleep 5
./bin/ceph mgr module enable cephadm
