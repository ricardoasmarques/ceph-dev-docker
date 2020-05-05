FROM opensuse/tumbleweed
LABEL maintainer="rimarques@suse.com"

RUN zypper --gpg-auto-import-keys ref
RUN zypper -n dup
RUN zypper -n install \
        iproute2 net-tools-deprecated zsh lttng-ust-devel babeltrace-devel \
        bash vim tmux git aaa_base ccache wget jq google-opensans-fonts psmisc \
        rpm-build smartmontools \
        python python-devel \
        python3-virtualenv \
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
        python3-PyYAML \
        python3-remoto \
        python3-requests \
        python3-Routes \
        python3-scipy \
        python3-Werkzeug \
        xvfb-run

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
ENV CYPRESS_CACHE_FOLDER /ceph/build/src/pybind/mgr/dashboard/cypress

VOLUME ["/ceph"]
VOLUME ["/shared"]

# Temporary fix for scipy issue in diskprection_local -> https://tracker.ceph.com/issues/43447
RUN zypper -n rm python3-scipy && pip3 install scipy==1.3.2

CMD ["zsh"]
