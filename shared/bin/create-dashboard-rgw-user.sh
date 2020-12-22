#!/bin/bash

set -e

: ${CEPH_DEV_DOCKER_CONFIG_DIR:="$HOME/.ceph-dev-docker"}
mkdir -p $CEPH_DEV_DOCKER_CONFIG_DIR

#--------------
# Configure RGW
#--------------

cd /ceph/build
./bin/radosgw-admin user create --uid=dev --display-name=Developer --system
./bin/ceph dashboard set-rgw-api-user-id dev

RGW_ACCESS_KEY="${CEPH_DEV_DOCKER_CONFIG_DIR}/rgw_access_key"
RGW_SECRET_KEY="${CEPH_DEV_DOCKER_CONFIG_DIR}/rgw_secret_key"
./bin/radosgw-admin user info --uid=dev | jq -jr ".keys[0].access_key" > $RGW_ACCESS_KEY
./bin/radosgw-admin user info --uid=dev | jq -jr ".keys[0].secret_key" > $RGW_SECRET_KEY
chmod 600 $RGW_ACCESS_KEY
chmod 600 $RGW_SECRET_KEY

./bin/ceph dashboard set-rgw-api-access-key -i $RGW_ACCESS_KEY || ./bin/ceph dashboard set-rgw-api-access-key "$(cat $RGW_ACCESS_KEY)"
./bin/ceph dashboard set-rgw-api-secret-key -i $RGW_SECRET_KEY || ./bin/ceph dashboard set-rgw-api-secret-key "$(cat $RGW_SECRET_KEY)"
