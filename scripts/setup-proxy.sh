#!/bin/bash

set -e

url=`ceph mgr services | jq .dashboard`

cdsdf
jq '.["/api/"].target'=$url proxy.conf.json.sample | jq '.["/ui-api/"].target'=$url > proxy.conf.json
