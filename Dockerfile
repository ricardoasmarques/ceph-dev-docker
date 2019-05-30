FROM opensuse/tumbleweed
LABEL maintainer="rimarques@suse.com"

RUN zypper --gpg-auto-import-keys ref
RUN zypper -n dup
RUN zypper -n install \
        iproute2 net-tools-deprecated zsh lttng-ust-devel babeltrace-devel \
        bash vim tmux git aaa_base ccache wget jq google-opensans-fonts psmisc \
        gcc8 gcc8-c++ libstdc++6-devel-gcc8 \
        python python-devel python2-virtualenv \
        python3-pip python3-devel \
        python3-bcrypt \
        python3-CherryPy \
        python3-Cython \
        python3-Jinja2 \
        python3-pecan \
        python3-PrettyTable \
        python3-PyJWT \
        python3-pylint \
        python3-pyOpenSSL \
        python3-requests \
        python3-Routes \
        python3-Werkzeug

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
ENV BUILD_DIR /ceph/build

VOLUME ["/ceph"]
VOLUME ["/shared"]

CMD ["zsh"]
