FROM opensuse:tumbleweed
MAINTAINER Ricardo Marques "rimarques@suse.com"

RUN zypper -n install python lttng-ust-devel babeltrace-devel

VOLUME  ["/ceph"]
