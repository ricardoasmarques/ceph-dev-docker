FROM opensuse:tumbleweed
LABEL maintainer="rimarques@suse.com"

RUN zypper -n ar https://download.opensuse.org/repositories/filesystems:/ceph:/nautilus/openSUSE_Tumbleweed/filesystems:ceph:nautilus.repo
RUN zypper --gpg-auto-import-keys ref
RUN zypper -n dup
RUN zypper -n install --oldpackage python3-Cython-0.28.4-1.1.x86_64 \
                                   python2-Cython-0.28.4-1.1.x86_64
RUN zypper -n install \
        iproute2 net-tools-deprecated python2-pip python3-pip \
        python lttng-ust-devel babeltrace-devel \
        librados2 python2-pylint python3-pylint \
        bash vim tmux git aaa_base ccache wget jq google-opensans-fonts \
        python-devel python3-devel \
        python-PrettyTable python3-PrettyTable psmisc python2-CherryPy \
        python3-CherryPy python2-pecan python3-pecan python2-Jinja2 \
        python3-Jinja2 python2-pyOpenSSL python3-pyOpenSSL \
        python3-Werkzeug python3-bcrypt python3-Routes python3-requests \
        gcc7 gcc7-c++ libstdc++6-devel-gcc7 python2-PyJWT python3-PyJWT

RUN wget https://dl.google.com/linux/linux_signing_key.pub
RUN rpm --import linux_signing_key.pub
RUN zypper ar http://dl.google.com/linux/chrome/rpm/stable/x86_64 google
RUN zypper -n in google-chrome-stable

ENV CHROME_BIN /usr/bin/google-chrome

ADD bin/ /root/bin/
ADD bash.bashrc /etc/bash.bashrc

ENV CEPH_ROOT /ceph
ENV BUILD_DIR /ceph/build

VOLUME ["/ceph"]

CMD /bin/bash
