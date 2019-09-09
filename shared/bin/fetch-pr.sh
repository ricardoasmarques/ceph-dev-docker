#!/bin/bash

##
# This will fetch, and optionally checkout, a PR from Ceph's github.
# fetch-pr.sh 1234 -c
# the above command will fetch PR #1234 and checkout it.
##

set -e

pr=$1

cd /ceph
git fetch https://github.com/ceph/ceph.git pull/$pr/head:pr/$pr -f

case "$2" in
--checkout|-c) git checkout pr/$pr ;;
esac
