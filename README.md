# ceph-dev-docker

The purpose of this docker image is to ease the local development of Ceph, by
providing a container-based runtime and development environment (based on
openSUSE "Tumbleweed").

It requires a local git clone to start up a
[vStart](http://docs.ceph.com/docs/master/dev/dev_cluster_deployement/)
environment.

## Usage

### Build the Image

From inside this project's git repo, run the following command:

    # docker build -t ceph-dev-docker .

You should now have two additional images in your local Docker repository, named
`ceph-dev-docker` and `docker.io/opensuse`:

    # docker images    
    REPOSITORY           TAG                 IMAGE ID            CREATED             SIZE
    ceph-dev-docker      latest              559deb8b9b4f        15 minutes ago      242 MB
    docker.io/opensuse   tumbleweed          f27ade5f6fe7        11 days ago         104 MB

### Clone Ceph

Somewhere else on your host system, create a local clone of the Ceph git
repository. Replace `<ceph-repository>` with the remote git repo you want to
clone from, e.g. `https://github.com/ceph/ceph.git`:

    # cd <workdir>
    # git clone <ceph-repository>
    # cd ceph

Now switch or create your development branch using `git checkout` or `git
branch`.
    
### Starting the Container and building Ceph

Now start up the container, by mounting the local git clone directory as
`/ceph`:

    # docker run -it -v $PWD:/ceph --net=host ceph-dev-docker /bin/bash

This will start up a shell running inside your development container. Inside the
container, you can now call `setup-ceph`, which will install all the required
build dependencies and then build Ceph from source.

    # setup-ceph -DWITH_PYTHON3=ON -DWITH_TESTS=OFF

### Create a new docker image with all dependencies installed (use a separate terminal)

Once the build has finished, it's helpful to perform a snapshot of this image,
to preserve the time-consuming step of installing the build dependencies. While
the container is still running, observe its `CONTAINER ID` and commit its state
into a new image:

     # docker ps -f ancestor=ceph-dev-docker
     # docker commit <CONTAINER_ID> ceph-dev-docker-build

### Running the container with all dependencies installed

     # docker run -it -v <ceph-repository>:/ceph --net=host ceph-dev-docker-build /bin/bash

### Start Ceph Development Environment

     # cd /ceph/build
     # ../src/vstart.sh -d -n -x

### Test Ceph Development Environment

     # cd /ceph/build
     # bin/ceph -s

### Stop Ceph development environment

     # cd /ceph/build
     # ../src/stop.sh
