FROM opensuse:tumbleweed
MAINTAINER Ricardo Marques "rimarques@suse.com"

RUN zypper -n install python lttng-ust-devel babeltrace-devel
RUN /ceph/install-deps.sh
# RUN make -j8

VOLUME  ["/ceph"]
