#!/bin/bash

set -e

zypper -n install nfs-ganesha nfs-ganesha-ceph nfs-ganesha-rados-grace nfs-ganesha-rados-urls
