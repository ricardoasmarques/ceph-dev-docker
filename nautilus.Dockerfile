FROM opensuse/leap:15.1
LABEL maintainer="rimarques@suse.com"

RUN zypper --gpg-auto-import-keys ref
RUN zypper -n dup
RUN zypper -n install \
        iproute2 net-tools-deprecated zsh lttng-ust-devel babeltrace-devel \
        bash vim tmux git aaa_base ccache wget jq google-opensans-fonts psmisc \
        python python2-pip python3-pip \
        python-devel python3-devel \
        python2-bcrypt python3-bcrypt \
        python2-CherryPy python3-CherryPy \
        python2-Cython python3-Cython \
        python2-Jinja2 python3-Jinja2 \
        python2-pecan python3-pecan \
        python2-PrettyTable python3-PrettyTable \
        python2-PyJWT python3-PyJWT \
        python2-pylint python3-pylint \
        python2-pyOpenSSL python3-pyOpenSSL \
        python2-requests python3-requests \
        python2-Routes python3-Routes \
        python2-Werkzeug python3-Werkzeug

# temporary fix for error regarding version of tempora
RUN pip2 install tempora==1.8 backports.functools_lru_cache
RUN pip3 install tempora==1.8 backports.functools_lru_cache

ADD /shared/docker/ /docker

# Chrome
RUN /docker/install-chrome.sh
ENV CHROME_BIN /usr/bin/google-chrome

# oh-my-zsh
ENV ZSH_DISABLE_COMPFIX true
RUN /docker/install-omz.sh

ENV CEPH_ROOT /ceph

ENV PATH="/shared/bin/nautilus:${PATH}"

VOLUME ["/ceph"]
VOLUME ["/shared"]

CMD ["zsh"]
