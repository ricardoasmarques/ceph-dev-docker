#!/bin/bash

set -e

cdsdf
source $SDP/node-env/bin/activate
npm i

npm run build

ceph mgr services

ceph mgr services | jq .dashboard
