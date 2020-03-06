FROM opensuse/leap:15.0
LABEL maintainer="rimarques@suse.com"

RUN zypper --gpg-auto-import-keys ref
RUN zypper -n dup
RUN zypper -n install \
        aaa_base babeltrace-devel bash bzip2 ccache git \
        google-opensans-fonts iproute2 jq lttng-ust-devel \
        net-tools-deprecated psmisc tar tmux vim wget zsh \
        python python2-pip python3-pip \
        python-devel python3-devel \
        python2-bcrypt python3-bcrypt \
        python2-CherryPy python3-CherryPy \
        python2-Cython python3-Cython \
        python2-pecan python3-pecan \
        python2-PrettyTable python3-PrettyTable \
        python2-pylint python3-pylint \
        python2-pyOpenSSL python3-pyOpenSSL \
        python2-requests python3-requests \
        python2-Routes python3-Routes \
        python2-Werkzeug python3-Werkzeug

ADD /shared/docker/ /docker

# Chrome
RUN /docker/install-chrome.sh
ENV CHROME_BIN /usr/bin/google-chrome

# oh-my-zsh
ENV ZSH_DISABLE_COMPFIX true
RUN /docker/install-omz.sh

ENV CEPH_ROOT /ceph

ENV PATH="/shared/bin/mimic:${PATH}"

VOLUME ["/ceph"]
VOLUME ["/shared"]

CMD ["zsh"]
