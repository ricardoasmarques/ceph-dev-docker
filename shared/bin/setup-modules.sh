#!/bin/bash

set -e

cd /ceph/build

bin/ceph dashboard set-grafana-api-url 'http://localhost:3000'

bin/ceph mgr module enable prometheus
bin/ceph dashboard set-prometheus-api-host 'http://localhost:9090'
bin/ceph dashboard set-alertmanager-api-host 'http://localhost:9093'