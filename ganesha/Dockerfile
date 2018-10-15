FROM centos:7

RUN rpm --import 'https://download.ceph.com/keys/release.asc'
ADD ceph.repo /etc/yum.repos.d/
RUN yum -y update
RUN yum -y install epel-release
RUN yum -y install https://download.ceph.com/nfs-ganesha/rpm-V2.6-stable/mimic/x86_64/libntirpc-1.6.2-0.1.el7.x86_64.rpm
RUN yum -y install https://download.ceph.com/nfs-ganesha/rpm-V2.6-stable/mimic/x86_64/nfs-ganesha-2.6.2-0.1.el7.x86_64.rpm
RUN yum -y install https://download.ceph.com/nfs-ganesha/rpm-V2.6-stable/mimic/x86_64/nfs-ganesha-ceph-2.6.2-0.1.el7.x86_64.rpm
RUN yum -y install https://download.ceph.com/nfs-ganesha/rpm-V2.6-stable/mimic/x86_64/nfs-ganesha-rgw-2.6.2-0.1.el7.x86_64.rpm

RUN yum -y install vim ceph-base python-ceph-compat
RUN yum -y install jq

ADD start.sh /

VOLUME ["/ceph"]

EXPOSE 111 111/udp 662 2049 38465-38467

ENTRYPOINT ["/start.sh"]

