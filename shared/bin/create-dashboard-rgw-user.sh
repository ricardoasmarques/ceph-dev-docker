#!/bin/bash

set -e

#--------------
# Configure RGW
#--------------

cd /ceph/build
./bin/radosgw-admin user create --uid=dev --display-name=Developer --system
./bin/ceph dashboard set-rgw-api-user-id dev
./bin/ceph dashboard set-rgw-api-access-key `./bin/radosgw-admin user info --uid=dev | jq -r ".keys[0].access_key"`
./bin/ceph dashboard set-rgw-api-secret-key `./bin/radosgw-admin user info --uid=dev | jq -r ".keys[0].secret_key"`
