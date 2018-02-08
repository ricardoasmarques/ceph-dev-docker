FROM opensuse:tumbleweed
MAINTAINER Ricardo Marques "rimarques@suse.com"

RUN zypper ref
RUN zypper -n dup
RUN zypper -n install \
        iproute2 net-tools-deprecated python2-pip python3-pip \
        python lttng-ust-devel babeltrace-devel \
        librados2 python2-pylint python3-pylint \
        bash vim tmux git aaa_base ccache \
        python-devel python-Cython python-PrettyTable

ADD setup-ceph.sh /root/bin/setup-ceph
ADD bash.bashrc /etc/bash.bashrc

VOLUME ["/ceph"]

CMD /bin/bash
