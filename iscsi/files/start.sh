#!/bin/bash

set -e

# Configure ceph
if [ ! -e /ceph/build/ceph.conf ]; then
 echo "No ceph cluster is running"
 exit 1
fi
mkdir -p /etc/ceph
MON_ADDRS=`cat /ceph/build/ceph.conf | grep 'mon addr' | sed -e 's/.*mon addr = //'`
MON_ADDRS=`echo $MON_ADDRS | sed 's/ /, /g'`
echo "[client]" > /etc/ceph/ceph.conf
echo "  mon host = $MON_ADDRS" >> /etc/ceph/ceph.conf
echo "  keyring = /etc/ceph/ceph.client.admin.keyring" >> /etc/ceph/ceph.conf
cp /ceph/build/keyring /etc/ceph/ceph.client.admin.keyring

# Configure iscsi-gateway
cat > /etc/ceph/iscsi-gateway.cfg <<EOF
# http://docs.ceph.com/docs/master/rbd/iscsi-target-cli/
[config]
cluster_name = ceph
gateway_keyring = ceph.client.admin.keyring
api_secure = false
api_user = admin
api_password = admin
api_port = 5001
trusted_ip_list = 172.18.0.1,172.18.0.2,172.18.0.3
EOF

if ! rados lspools | grep -q '^rbd$'; then
  ceph osd pool create rbd 1 1
fi
#bin/rados -p rbd put gateway.conf <file>
#bin/rados -p rbd get gateway.conf out.json
#rm -f /etc/ceph/iscsi-gateway.cfg

mount -t configfs none /sys/kernel/config

# Start ceph-iscsi-config
/usr/bin/rbd-target-gw &

# Start ceph-iscsi-cli
/usr/bin/rbd-target-api &

mkdir -p /etc/target

touch /var/log/rbd-target-api.log
touch /var/log/rbd-target-gw.log
tail -f -n100 /var/log/rbd-target*.log

# TODO config hosts
# gwcli
# cd /iscsi-target
# create iqn.2003-01.com.redhat.iscsi-gw:iscsi-igw
# cd iqn.2003-01.com.redhat.iscsi-gw:iscsi-igw/gateways
# create ceph-gw-1 172.18.0.3 skipchecks=true
# create ceph-gw-2 172.18.0.2 skipchecks=true
# grep 0CBC /proc/net/tcp
# /proc/net/tcp
