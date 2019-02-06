#!/bin/bash

set -e

find /ceph/build/ -name "mgr.*.log" -type f -delete

cd /ceph/build
RGW=1 ../src/vstart.sh -d -n -x

setup-proxy.sh

#--------------
# Configure RGW
#--------------

./bin/radosgw-admin user create --uid=dev --display-name=Developer --system

./bin/ceph dashboard set-rgw-api-user-id dev
./bin/ceph dashboard set-rgw-api-access-key `./bin/radosgw-admin user info --uid=dev | jq .keys[0].access_key | sed -e 's/^"//' -e 's/"$//'`
./bin/ceph dashboard set-rgw-api-secret-key `./bin/radosgw-admin user info --uid=dev | jq .keys[0].secret_key | sed -e 's/^"//' -e 's/"$//'`
./bin/ceph dashboard iscsi-gateway-add node1 http://admin:admin@192.168.100.201:5001
./bin/ceph dashboard iscsi-gateway-add node2 http://admin:admin@192.168.100.202:5001
./bin/ceph dashboard iscsi-gateway-add node3 http://admin:admin@192.168.100.203:5001
./bin/ceph dashboard iscsi-gateway-list

