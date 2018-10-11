#!/bin/bash

set -e

ceph mgr module disable dashboard
clear-log-and-pyc

# By setting the dashboard to a static port
# you don't have to rerun 'npm start'
ceph config set mgr mgr/dashboard/x/server_port 8383

sleep 5
ceph mgr module enable dashboard

sleep 5
setup-proxy.sh
