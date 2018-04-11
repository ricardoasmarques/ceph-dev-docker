FROM opensuse:tumbleweed
LABEL maintainer="rimarques@suse.com"

RUN zypper addrepo https://download.opensuse.org/repositories/security/openSUSE_Tumbleweed/security.repo
RUN zypper ref
RUN zypper -n dup
RUN zypper -n install \
        iproute2 net-tools-deprecated python2-pip python3-pip \
        python lttng-ust-devel babeltrace-devel \
        librados2 python2-pylint python3-pylint \
        bash vim tmux git aaa_base ccache wget jq google-opensans-fonts \
        oath-toolkit python-devel python-Cython python-PrettyTable psmisc \
        python2-CherryPy python2-pecan python2-Jinja2 python2-pyOpenSSL

RUN wget https://dl.google.com/linux/linux_signing_key.pub
RUN rpm --import linux_signing_key.pub
RUN zypper ar http://dl.google.com/linux/chrome/rpm/stable/x86_64 google
RUN zypper -n in google-chrome-stable

ENV CHROME_BIN /usr/bin/google-chrome

ADD setup-ceph.sh /root/bin/setup-ceph
ADD bash.bashrc /etc/bash.bashrc

VOLUME ["/ceph"]

CMD /bin/bash
