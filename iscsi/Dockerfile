FROM centos:7

RUN rpm --import 'https://download.ceph.com/keys/release.asc'
ADD files/ceph.repo /etc/yum.repos.d/
RUN yum -y update
RUN yum -y install epel-release

RUN yum -y install git
RUN yum -y install python-setuptools
RUN yum -y install pyOpenSSL

# Install ceph
RUN yum -y install ceph-base

# Install targetcli
WORKDIR /
RUN git clone https://github.com/open-iscsi/targetcli-fb.git
WORKDIR /targetcli-fb
RUN python setup.py install

# Install configshell
WORKDIR /
RUN git clone https://github.com/open-iscsi/configshell-fb.git
WORKDIR /configshell-fb
RUN python setup.py install

#Install python-rtslib
WORKDIR /
RUN git clone https://github.com/open-iscsi/rtslib-fb.git
WORKDIR /rtslib-fb
RUN python setup.py install

# Install tcmu-runner
WORKDIR /
RUN git clone https://github.com/open-iscsi/tcmu-runner.git
WORKDIR /tcmu-runner
RUN ./extra/install_dep.sh
RUN cmake -Dwith-glfs=false -Dwith-qcow=false -DSUPPORT_SYSTEMD=ON -DCMAKE_INSTALL_PREFIX=/usr .
RUN make
RUN make install

# Install ceph-iscsi-config
WORKDIR /
RUN git clone https://github.com/ceph/ceph-iscsi-config.git
WORKDIR /ceph-iscsi-config
RUN python setup.py install
RUN yum -y install python-netifaces python-flask python-netaddr python-crypto

# Install ceph-iscsi-cli
WORKDIR /
RUN git clone https://github.com/ceph/ceph-iscsi-cli.git
WORKDIR /ceph-iscsi-cli
RUN python setup.py install
# RUN yum -y install python-configshell

EXPOSE 3260 5000 5001

ADD files/start.sh /

ENTRYPOINT [ "/start.sh" ]
