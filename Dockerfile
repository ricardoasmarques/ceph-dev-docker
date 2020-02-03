FROM opensuse/tumbleweed
LABEL maintainer="rimarques@suse.com"

RUN zypper --gpg-auto-import-keys ref
RUN zypper -n dup
RUN zypper -n install \
        aaa_base \
        babeltrace-devel \
        bash \
        ccache \
        git \
        google-opensans-fonts \
        iproute2 \
        jq \
        lttng-ust-devel \
        net-tools-deprecated \
        psmisc \
        python \
        python-devel \
        python2-virtualenv \
        python3-CherryPy \
        python3-Cython \
        python3-Jinja2 \
        python3-PrettyTable \
        python3-PyJWT \
        python3-PyYAML \
        python3-Routes \
        python3-Werkzeug \
        python3-bcrypt \
        python3-devel \
        python3-pecan \
        python3-pip \
        python3-pyOpenSSL \
        python3-pylint \
        python3-remoto \
        python3-remoto \
        python3-requests \
        python3-scipy

# temporary fix for error regarding version of tempora
RUN pip3 install tempora==1.8 backports.functools_lru_cache

ADD /shared/docker/ /docker

# Chrome
RUN /docker/install-chrome.sh
ENV CHROME_BIN /usr/bin/google-chrome

# oh-my-zsh
ENV ZSH_DISABLE_COMPFIX true
RUN /docker/install-omz.sh

ENV CEPH_ROOT /ceph

VOLUME ["/ceph"]
VOLUME ["/shared"]

# Temporary fix for scipy issue in diskprection_local -> https://tracker.ceph.com/issues/43447
RUN zypper -n rm python3-scipy && pip3 install scipy==1.3.2

CMD ["zsh"]
