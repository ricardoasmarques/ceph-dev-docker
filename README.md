# ceph-dev-docker

The purpose of this docker image is to ease the local development of Ceph, by
providing a container-based runtime and development environment (based on
openSUSE "Tumbleweed").

It requires a local git clone to start up a
[vStart](http://docs.ceph.com/docs/master/dev/dev_cluster_deployement/)
environment.

## Usage

### docker user group

`docker` command requires root privileges.
To remove this requirement you can join the `docker` user group.

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

    # docker run -itd \
      -v $PWD:/ceph \
      -v <CCACHE_DIR>:/root/.ccache \
      --net=host \
      --name=ceph-dev \
      --hostname=ceph-dev \
      --add-host=ceph-dev:127.0.0.1 \
      ceph-dev-docker \
      /bin/bash

Lets walk through some of the flags from the above command:
- `-d`: runs the container shell in detach mode
 - `<CCACHE_DIR>`: the directory where ccache will store its data
 - `--name`: custom name for the container, this can be used for managing
    the container
 - `--hostname`: custom hostname for the docker container, it helps to
    distinguish one container from another
 - `--add-host`: fixes the problem with resolving hostname inside docker

After running this command you will have a running docker container.
Now, anytime you want to access the container shell you just have to run

    # docker attach ceph-dev

Inside the container, you can now call `setup-ceph`, which will install all the
required build dependencies and then build Ceph from source.

    (docker)# setup-ceph

### Docker container lifecycle

To start a container run,

    # docker start ceph-dev

And to attach to a running container shell,

    # docker attach ceph-dev

If you want to detach from the container and stop the container,

    (docker)# exit

However if you want to simply detach, without stoping the container,
which would allow you to reattach at a later time,

    (docker)# CTRL+P CTRL+Q

Finally, to stop the container,

    # docker stop ceph-dev

## Multiple docker container

If you want to run multiple docker container, you just need to modify the
previous `docker run` command with a different local ceph directory and replace
`ceph-dev` with a new value.

For example:

    # docker run -itd \
      -v $PWD:/ceph \
      -v <CCACHE_DIR>:/root/.ccache \
      --net=host \
      --name=new-ceph-container \
      --hostname=new-ceph-container \
      --add-host=new-ceph-container:127.0.0.1 \
      ceph-dev-docker \
      /bin/bash

Now if you want to access this container just run,

    # docker attach new-ceph-container

### Start Ceph Development Environment

To start up the compiled Ceph cluster, you can use the `vstart.sh` script, which
spawns up an entire cluster (MONs, OSDs, Mgr) in your development environment or
you can use the `ceph-start` script available in this docker image.
See the
[documentation](http://docs.ceph.com/docs/master/dev/dev_cluster_deployement/)
and the output of `vstart.sh --help` for details.

To start an environment from scratch with debugging enabled, use the following command:

    (docker)# start-ceph

**Note:** This script uses the `vstart` `-d` option that enables debug output. Keep a close eye on the growth
of the log files created in `build/out`, as they can grow very quickly (several
GB within a few hours).

### Test Ceph Development Environment

    (docker)# cd /ceph/build
    (docker)# bin/ceph -s

### Stop Ceph development environment

    (docker)# stop-ceph

## Working on ceph dashboard

There are some scripts that can be useful if you are working on ceph dashboard.

### Reload dashboard module (Backend)

Run the following script to reflect changes in python files:

    (docker)# reload-dashboard.sh

### Start development server (Frontend)

The following script will start a frontend development server that can be
accessed at [http://localhost:4200](http://localhost:4200):

    (docker)# npm-start.sh

## External services

To run preconfigured external services, you can simply use `docker-compose`.

> If you do not have `docker-compose` installed on your system, follow these
[instructions](https://docs.docker.com/compose/install/).

Running the following command will start all containers, one for each service.

    docker-compose up

Note that this will *not* start `ceph-dev-docker`.

Stopping these containers is as easy as running them:

    docker-compose down

You may want to check the help of docker-compose for starting up containers. It
contains descriptions on how to force recreation of containeres of rebuilding
them:

    docker-compose help up

After starting all containers, the following external services will be available:

| Tool           | URL                   | User                       | Pass  |
| -------------- | --------------------- | -------------------------- | ----- |
| Grafana        |                       |                            |       |
| Prometheus     |                       |                            |       |
| Node Exporter  |                       |                            |       |
| LDAP           | ldap://localhost:2389 | cn=admin,dc=example,dc=org | admin |
| PHP LDAP Admin | https://localhost:90  | cn=admin,dc=example,dc=org | admin |

> Please note that Grafana isn't configured automatically for you, so you
will have to follow these
[instructions](https://github.com/ceph/ceph/blob/master/doc/mgr/dashboard.rst#enabling-grafana-dashboards)
to configure Grafana accordingly. The changes although, are persisted.

## Troubleshooting

If you encounter a `permisson denied` when trying to access `/ceph` by, for instance, running `setup-ceph.sh` or simply by trying to list its contents (to verify that it has been mounted correctly), the chances are high that your host system uses SELinux. To circumvent that problem, you can simply disable SELinux by running:

    sudo setenforce permissive

This puts SELinux in permissive mode, where the rules are still evaluated but not enforced, they are only logged. This basically *disables* SELinux, making the host system more vulnerable for security flaws.
