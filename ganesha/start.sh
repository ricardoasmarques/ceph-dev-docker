#!/bin/sh

: ${LOG_LEVEL:="NIV_EVENT"}

init_rpc() {
  if [ ! -x /run/rpcbind ] ; then
    install -m755 -g 32 -o 32 -d /run/rpcbind
  fi
  rpcbind || return 0
  rpc.statd -L || return 0
  rpc.idmapd || return 0
  sleep 1
}

init_dbus() {
  if [ ! -x /var/run/dbus ] ; then
    install -m755 -g 81 -o 81 -d /var/run/dbus
  fi
  rm -f /var/run/dbus/*
  rm -f /var/run/messagebus.pid
  dbus-uuidgen --ensure
  dbus-daemon --system --fork
  sleep 1
}

if [ ! -e /ceph/build/ceph.conf ]; then
  echo "No ceph cluster is running"
  exit 1
fi

MON_ADDRS=`cat /ceph/build/ceph.conf | grep 'mon addr' | sed -e 's/.*mon addr = //'`
MON_ADDRS=`echo $MON_ADDRS | sed 's/ /, /g'`

mkdir -p /etc/ceph
echo "[client]" > /etc/ceph/ceph.conf
echo "  mon host = $MON_ADDRS" >> /etc/ceph/ceph.conf
cp /ceph/build/keyring /etc/ceph/

mkdir -p /var/lib/ceph/radosgw/ceph-admin/
cp /etc/ceph/keyring /var/lib/ceph/radosgw/ceph-admin/

init_rpc
init_dbus

RGW_AK=`radosgw-admin user info --uid=testid | jq .keys[0].access_key`
RGW_SK=`radosgw-admin user info --uid=testid | jq .keys[0].secret_key`

cat >/etc/ganesha/my.conf <<EOF
EXPORT {
  Export_ID=1;
  Path = /;
  Pseudo = /cephfs/;
  Protocols = 3, 4;
  Access_Type = RW;
  Transports = UDP, TCP;
  FSAL {
    Name = CEPH;
    User_ID = "fs";
  }
}

EXPORT {
  Export_ID=2;
  Path = "/";
  Pseudo = "/rgw/";
  Access_Type = RW;
  Protocols = 3, 4;
  Transports = UDP, TCP;
  FSAL {
    Name = RGW;
    User_Id="testid";
    Access_Key_Id=${RGW_AK};
    Secret_Access_Key=${RGW_SK};
  }
}
EOF

if ! rados lspools | grep -q '^ganesha$'; then
  ceph osd pool create ganesha 1 1
fi

if ! rados -p ganesha ls | grep -q '^ganesha.conf$'; then
  rados -p ganesha put ganesha.conf /etc/ganesha/my.conf
fi

cat >/etc/ganesha/rados.conf <<EOF

RADOS_URLS {
  # Path to a ceph.conf file for this cluster.
  Ceph_Conf = /etc/ceph/ceph.conf;

  # RADOS_URLS use their own ceph client too. Authenticated access
  # requires a cephx keyring file.
  UserId = "admin";
}

%url rados://ganesha/ganesha.conf
EOF

NFS_SERVER_IP=`ip addr  | grep eth0 | tail -1 | sed 's/.*inet \(.*\)\/.*/\1/g'`
echo "########################################################################"
echo "#      NFS SERVER IP : $NFS_SERVER_IP"
echo "#"
echo "# CephFS mount: sudo mount -t nfs ${NFS_SERVER_IP}:/cephfs/ /mnt"
echo "# RGW mount:    sudo mount -t nfs ${NFS_SERVER_IP}:/rgw/ /mnt"
echo "########################################################################"

/usr/bin/ganesha.nfsd -F -L /dev/stdout -f /etc/ganesha/rados.conf -N ${LOG_LEVEL}

