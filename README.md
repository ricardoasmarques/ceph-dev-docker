# ceph-dev-docker

The purpose of this docker image is to help in the development of ceph.

## Usage

### Clone ceph

    # git clone <repo>
    # git submodule update --init --recursive

### Image build

    # docker build -t ceph-dev-docker .

### Running the container

    # docker run -it -v /home/rimarques-local/projects/ceph:/ceph --net=host ceph-dev-docker /bin/bash

Please note that the mapped Ceph source cannot be used in the Docker container if `./do_cmake.sh` has been called with a path not used by the Docker container.  The source, taken from the example above, is `/home/rimarques-local/projects/ceph` in this case.  If it doesn't compile (due to wrong paths), use a dedicated Ceph source for the Docker container where `./do_cmake.sh` hasn't been called before.

    # cd /ceph
    # ./install-deps.sh
    # ./do_cmake.sh
    # cd /ceph/build
    # make -j8

### Create a new docker image with all dependencies installed (use a separate terminal)

     # docker ps
     # docker commit <CONTAINER_ID> ceph-dev-docker-build

### Running the container with all dependencies installed

     # docker run -it -v /home/rimarques-local/projects/ceph:/ceph --net=host ceph-dev-docker-build /bin/bash

### Start ceph development environment

     # cd /ceph/build
     # ../src/vstart.sh -d -n -x

### Test ceph development environment

     # cd /ceph/build
     # bin/ceph -s

### Stop ceph development environment

     # cd /ceph/build
     # ../src/stop.sh


