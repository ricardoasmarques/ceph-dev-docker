#!/bin/bash

set -e

cd /ceph/build
RGW=1 ../src/vstart.sh -d -n -x

#--------------
# Configure RGW
#--------------

./bin/radosgw-admin user create --uid=dev --display-name=Developer --system

access_key=`./bin/radosgw-admin user info --uid=dev | jq .keys[0].access_key | sed -e 's/^"//' -e 's/"$//'`
./bin/ceph dashboard set-rgw-api-access-key $access_key

secret_key=`./bin/radosgw-admin user info --uid=dev | jq .keys[0].secret_key | sed -e 's/^"//' -e 's/"$//'`
./bin/ceph dashboard set-rgw-api-secret-key $secret_key
