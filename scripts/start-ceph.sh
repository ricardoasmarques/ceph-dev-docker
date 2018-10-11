#!/bin/bash

set -e

cdb

clear-log-and-pyc

RGW=1 ../src/vstart.sh -d -n -x

#--------------
# Configure RGW
#--------------

./bin/radosgw-admin user create --uid=dev --display-name=Developer --system

ceph dashboard set-rgw-api-user-id dev
ceph dashboard set-rgw-api-access-key `./bin/radosgw-admin user info --uid=dev | jq .keys[0].access_key | sed -e 's/^"//' -e 's/"$//'`
ceph dashboard set-rgw-api-secret-key `./bin/radosgw-admin user info --uid=dev | jq .keys[0].secret_key | sed -e 's/^"//' -e 's/"$//'`

#-----------------------------
# Add test pool to create RBDs
#-----------------------------

ceph osd pool create rbdPool 16
ceph osd pool application enable rbdPool rbd

reload-dashboard.sh
