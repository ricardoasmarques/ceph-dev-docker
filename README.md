# ceph-dev-docker

The purpose of these docker images is to ease the local development of Ceph, by
providing a container-based runtime and development environment (based on
openSUSE "Tumbleweed").

It requires a local git clone to start up a
[vStart](http://docs.ceph.com/docs/master/dev/dev_cluster_deployement/)
environment.

## Usage

### Docker User Group

The `docker` command usually requires root privileges. On some Linux
distributions, you can add your user account to the `docker` user group to
remove this requirement.

### Older Ceph Releases

When developing for older ceph versions you should use the dedicated dockerfile
for that release, p.e. we have a `mimic.Dockerfile`.

To create a container with that dockerfile you can either call `setup.sh` with
`VERSION` var specified or add `-f <version>.Dockerfile` to the docker build
command.

For each release there will exist a specific bin folder that will have priority
over the shared bin scripts.

### setup.sh

This script can be used to get a working container with 1 command.

It will remove the previous container (with the same name), rebuild the image
and create a new container.

The image will not be removed, so it will be an
incremental build.

You can customize the outcome of the script with the following env variables:

- `NAME` - Name of the container. If you want more than 1 container you need to
change this. Default: `ceph-1`.
- `CEPH` - Path to the ceph repository. Default: `../ceph`
- `CCACHE` - Path to ccache. Default: `../ceph-ccache`
- `VERSION` - Specify an already released ceph version which you are going work
on. Default: `master`. Available versions: `mimic`, `nautilus`.

Note: `CEPH` and `CCACHE` need to be absolute paths.


### Build the Image

From inside this project's git repo, run the following command:

    # docker build --network=host -t ceph-dev-docker .

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

### Starting the Container and Building Ceph

Now start up the container, by mounting the local git clone directory as
`/ceph`:

    # docker run -itd \
      -v <CEPH_ROOT>:/ceph \
      -v <CCACHE_ROOT>:/root/.ccache \
      -v <CEPH_DEV_DOCKER_ROOT>/shared:/shared \
      --net=host \
      --name=ceph-dev \
      --hostname=ceph-dev \
      --add-host=ceph-dev:127.0.0.1 \
      ceph-dev-docker

Lets walk through some of the flags from the above command:
- `-d`: runs the container shell in detach mode
 - `<CCACHE_ROOT>`: the directory where ccache will store its data
 - `--name`: custom name for the container, this can be used for managing
    the container
 - `--hostname`: custom hostname for the docker container, it helps to
    distinguish one container from another
 - `--add-host`: fixes the problem with resolving hostname inside docker

Extra flags:

- `--env CEPH_PORT=<CEPH_PORT>`: This port will be used by `vstart.sh` to
determine each service's port.
All services will have a port with an increment of 1000 relative to the previous
one; and since the dashboard is currently the first one its port will be
<CEPH_PORT>+1000.
Make sure the <CEPH_PORT> you pick won't cause conflicts in your environment.

After running this command you will have a running docker container.
Now, anytime you want to access the container shell you just have to run

    # docker attach ceph-dev

Inside the container, you can now call `setup-ceph.sh`, which will install all
the required build dependencies and then build Ceph from source.

    (docker)# setup-ceph.sh

This script reads the following env variables:

    // Determines which gcc version should be used. If 'true' it will use gcc7,
    // which is compatible with the mimic release
    // default: false
    MIMIC=true

    // Forces the use of a specific python version.
    // default: 3
    WITH_PYTHON=2

    // Forces a clean compilation of ceph. It will remove the build folder and
    // node_modules and dist from the dashboard
    // default: false
    CLEAN=true

### Docker Container Lifecycle

To start a container run,

    # docker start ceph-dev

And to attach to a running container shell,

    # docker attach ceph-dev

Or to create a new session to the same container,

    # docker exec -it ceph-dev /bin/zsh

If you want to detach from the container and stop the container,

    (docker)# exit

However if you want to simply detach, without stoping the container,
which would allow you to reattach at a later time,

    (docker)# CTRL+P CTRL+Q

Finally, to stop the container,

    # docker stop ceph-dev

### Multiple Docker Containers

If you want to run multiple docker containers, you just need to modify the
previous `docker run` command with a different local ceph directory and replace
`ceph-dev` with a new value.

For example:

    # docker run -itd \
      -v <CEPH_ROOT>:/ceph \
      -v <CCACHE_ROOT>:/root/.ccache \
      -v <CEPH_DEV_DOCKER_ROOT>/shared:/shared \
      --net=host \
      --name=new-ceph-container \
      --hostname=new-ceph-container \
      --add-host=new-ceph-container:127.0.0.1 \
      ceph-dev-docker

Now if you want to access this container just run,

    # docker attach new-ceph-container

## Working on Ceph Dashboard

There are some scripts that can be useful if you are working on Ceph Dashboard.

All of them are now accessible through the `dash` command:

    (docker)# dash

When you press `tab` it will show you a list of all scripts and their
description.

### Start Ceph Development Environment

To start up the compiled Ceph cluster, you can use the `vstart.sh` script, which
spawns up an entire cluster (MONs, OSDs, Mgr) in your development environment or
you can use the `start-ceph.sh` script available in this docker image.

See the
[documentation](http://docs.ceph.com/docs/master/dev/dev_cluster_deployement/)
and the output of `vstart.sh --help` for details.

To start an environment from scratch with debugging enabled, use the following
command:

    (docker)# start-ceph.sh
    # OR
    (docker)# dash start-ceph

**Note:** This script uses the `vstart` `-d` option that enables debug output.
Keep a close eye on the growth of the log files created in `build/out`, as they
can grow very quickly (several GB within a few hours).

### Test Ceph Development Environment

    (docker)# cd /ceph/build
    (docker)# bin/ceph -s

### Stop Ceph Development Environment

    (docker)# stop-ceph.sh
    # OR
    (docker)# dash stop-ceph

### Reload Dashboard Module (Backend)

Run the following script to reflect changes in python files:

    (docker)# reload-dashboard.sh
    # OR
    (docker)# dash reload-dashboard

### Start Development Server (Frontend)

The following script will start a frontend development server that can be
accessed at [http://localhost:4200](http://localhost:4200):

    (docker)# npm-start.sh
    # OR
    (docker)# dash npm-start

## External Services

To run preconfigured external services, you can simply use `docker-compose`.

> If you do not have `docker-compose` installed on your system, follow these
[instructions](https://docs.docker.com/compose/install/).

### Starting Services

Running the following command will start all containers, one for each service.

    docker-compose up

Note that this will *not* start `ceph-dev-docker`. See the instructions above on
how to perform this task.

You can also start a single service by providing the name of the services as
they are configured in the `docker-compose.yml` file.

	docker-compose up grafana

Stopping these containers is as easy as running them:

    docker-compose down

You may want to check the help of docker-compose for starting up containers. It
contains descriptions on how to force recreation of containeres of rebuilding
them:

    docker-compose help up

After starting all containers, the following external services will be available:

| Service        | URL                   | User                       | Pass  |
| -------------- | --------------------- | -------------------------- | ----- |
| Grafana        | http://localhost:3000 | admin                      | admin |
| Prometheus     | http://localhost:9090 | -                          | -     |
| Alertmanager   | http://localhost:9093 | -                          | -     |
| Node Exporter  | http://localhost:9100 | -                          | -     |
| Keycloak       | http://localhost:8080 | admin                      | admin |
| LDAP           | ldap://localhost:2389 | cn=admin,dc=example,dc=org | admin |
| PHP LDAP Admin | https://localhost:90  | cn=admin,dc=example,dc=org | admin |
| Shibboleth     | http://localhost:9080/Shibboleth.sso/Login | admin     | admin |
| HAProxy        | https://localhost/    | -                          | -     |

### Enabling Prometheus

All TCP ports in use can be found in `prometheus/prometheus.yml`.

To start Prometheus, Grafana and Node exporter, run:

    docker-compose up alertmanager grafana node-exporter prometheus

In order to connect with Prometheus to your running docker instance, enable
Prometheus in it with:

    ceph mgr module enable prometheus

Now the following services should be found:

* [Ceph metrics](http://localhost:9100/metrics)
* [Prometheus](http://localhost:9090)
* [Alertmanager](http://localhost:9093)
* [Grafana](http://localhost:3000)

In order to enable connections from the dashboard to the Alertmanager API run:

    ceph dashboard set-alertmanager-api-host 'http://localhost:9093'

After you have connected the API to the dashboard reload the page.
After some minutes you should see a new tab inside the notification popover.
The monitoring tab should have at least one active alert named 'load0'.

There are 7 alerts configured, you can find them in 'prometheus/alert.rules'.
The alerts have nothing to do with your cluster state (ATM), just with your system load.
'load0' fires if your system load is greater than zero, this means it's always on.

### Enabling Grafana

The Grafana container is pre-configured to access the Prometheus container as
a data source. The Grafana dashboards are taken from the ceph git repository
when creating the container (by assuming that the ceph git repo is located
in the same directory as the ceph-dev-docker git repo). Grafana scans this
directory for changes every 10 seconds.

To configure the embedding of the Grafana dashboards into the Ceph Manager
Dashboard, run the following command inside the ceph-dev container where Ceph
is up and running::

    (ceph-dev)# bin/ceph dashboard set-grafana-api-url http://localhost:3000

See the Ceph Dashboard documentation for additional information about the
Grafana integration.

#### Enabling SSL

To enable SSL in Grafana you need to modify the 'grafana/grafana.ini' file.

    [server]
    protocol = https

After that run the following command inside the ceph-dev container where Ceph
is up and running::

    (ceph-dev)# bin/ceph dashboard set-grafana-api-url https://localhost:3000

### Configuring SSO

Add the following entry to your `/etc/hosts`:

    <your_ip> cephdashboard.local

Access `ceph-dev` container:

    # docker exec -it ceph-dev bash

    (ceph-dev)# cd /ceph/build

Start Ceph Dashboard (if it's not already running):

    (ceph-dev)# start-ceph

Ceph Dashboard should be running on port 433:

    (ceph-dev)# bin/ceph config set mgr mgr/dashboard/x/ssl_server_port 443

    (ceph-dev)# bin/ceph mgr module disable dashboard

    (ceph-dev)# bin/ceph mgr module enable dashboard

    (ceph-dev)# bin/ceph mgr services

Setup SSO on Ceph Dashboard:

    (ceph-dev)# cat <<EOF > sp_x_509_cert
MIIDYDCCAkigAwIBAgIJAOwAnH/ZKuTnMA0GCSqGSIb3DQEBCwUAMEUxCzAJBgNVBAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVQQKDBhJbnRlcm5ldCBXaWRnaXRzIFB0eSBMdGQwHhcNMTgwOTI0MTA0ODQwWhcNMjgwOTIzMTA0ODQwWjBFMQswCQYDVQQGEwJBVTETMBEGA1UECAwKU29tZS1TdGF0ZTEhMB8GA1UECgwYSW50ZXJuZXQgV2lkZ2l0cyBQdHkgTHRkMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArdsf7uMypSF/6/7W+dKGsveHa3nbkKRPbXAP9P9a9hb3vxVkd6Qqsgf4WJrwRAl1I5Hhfz6AfHDVJFJg+TDKBlba2NXASxGMWYcgdvAvzyrWaIfGUhajZ/cE2Zz16qs3nIY88jXqaVQIFhESBk9uc3aK3RGgLTb6ytWRlP/EMQZ8pxlQUYUuqvKMCBifJTUPDyGiqnaQ826W1zi1qMcHmbRQbmprU/g1na6rAX1OJPwMgovrMvQKR9PuMmUDauLQI3iWHzy3t+02rKUAHWGF2Xfel3RCSXWp+o6nBRrUnl642zAvXuoGYyJLTqXbziD2CVT0uA8SuH/w/UFFflWEEwIDAQABo1MwUTAdBgNVHQ4EFgQUDr2DkSCj8i5I8JfmN/9SbaqrR8UwHwYDVR0jBBgwFoAUDr2DkSCj8i5I8JfmN/9SbaqrR8UwDwYDVR0TAQH/BAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEACqtiY50kaOt+lKNRlOsqMRe5YftjWNF53CP2jAFpE4n7tVDGnO8c2+gDJL7Fc9VkcfZzYArpzcdcXMMKD/Kp4L/zzPpIiVxZtqRw3A+xNkZ6yKLz6aZAY/2wIcVwXBGvDFIHYuzfS5YTp9oAX9M+izTt4HuP20GuyCNWIE/ME5QUaJ62Z+nJdCd43Eg4gq67+whSWaL6GdiW1y+Fcj4nAEWMKNccDeCWI9FTG/aTmliazvHSxOi6Z3mcQNs0VIgBlbuVmXruJEFPv40okY5drFZbR4ZjjSbZPckXVs62fTV+q5RtrTQd8+g5ifci+TOyPEktC49FKanZR6L0TI+E8g==
EOF

    (ceph-dev)# cat <<EOF > sp_private_key
MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCt2x/u4zKlIX/r/tb50oay94dreduQpE9tcA/0/1r2Fve/FWR3pCqyB/hYmvBECXUjkeF/PoB8cNUkUmD5MMoGVtrY1cBLEYxZhyB28C/PKtZoh8ZSFqNn9wTZnPXqqzechjzyNeppVAgWERIGT25zdordEaAtNvrK1ZGU/8QxBnynGVBRhS6q8owIGJ8lNQ8PIaKqdpDzbpbXOLWoxweZtFBuamtT+DWdrqsBfU4k/AyCi+sy9ApH0+4yZQNq4tAjeJYfPLe37TaspQAdYYXZd96XdEJJdan6jqcFGtSeXrjbMC9e6gZjIktOpdvOIPYJVPS4DxK4f/D9QUV+VYQTAgMBAAECggEAAj0sMBtk75N63kMt6ZG4gl2FtPCgz0AOdc5XpkQTm8+36RIRdSj8E8bef+We6oFkrMyYJtdbOD8Lv6f/77WdJG/B6cD29QCI2i5PULjPJM/cawQ0naIFALXBrjvDPv5tfOqNpmDjX+/hGself8dOGNaR+z7a3To0CKCve0e/8xGo3uNhPBByvrGgdZK6LQKOeo387zKRwDG2Pi4+e5kfGwOYB4tfPZOMVMEuFAV+MJ9xb6N2lp/n1Qxo9ceEiOxjJGzQygJJUquIe+koQfKcZ/iah5mi8BaEdXYKIklDxEJijXmfEwjFE2yrYqV1HZ2iuOzdeVgeCeloYST/BxHNwQKBgQDiIV9TvW2/T/HBSA/yUjmO9r93oXTb0lMvfHurKBF1t65aAztpq8sIZ/4JrfEkumo1KA5Nm+Z3nPY5dEpO4A/CSUXX8iCMQSbE/Sk2PspReG1hSsYMMZYKIXUp8fE3zZHnUuXug+4pjMKzcD2hNKj37uFTn5BlQyXnn0Uap/AfuwKBgQDE0hYobMGnbRbjQhm8rSYeslPDjDC8yLOJW83TWMqWseMRXzuB+dU+Gooo2SMmWRatKuZ+oACx7E8k6aMaUrv7aCnht7QH/TBBUsb10ZZ9mvi+wRqiw7drrxcvU6X07A17bsIzT4FJ+QdisUKwkVrFhCGcySZLyAWgQHMD/i6LiQKBgFEJYJ4j3naW8a4wYvaWHOZs6sS2aah1QTZdR/xYSZmED8lWKy59UC9dBR725Noiq/kMt8N8QSVQbLS+RfrqNPuNQqhWru9UUc56YxB7hAmaPKiHIV4xTvGmd9RmTemPk9/wR1IomWrudL/VU2C3/G2Nf9Z18ks3uxe8bglVcaoNAoGAP/3+bk5N+F2jn2gSbiHtzvUz/tRJ1Fd86CANH7YyyCQ2K6PG+U99YZ/HY9iVcRZuJQdZwbnMAA1Q/jNocFqN/AO1+kl8I0zSr6p2Pd5TC6ujTIIEYv83V6+p3h1YS/WjvIoaYgxrgN2S5Se1Ayt/U9DODOfpp6H1ElFiE95Ey+ECgYA8vcf0CBCcVTUitTAFTPDFujFKlQ1a9HHbu3qFPP5A/Jo6Ki4eqmZfCBH7ZB/B1oOf0Jb/Er24nAql8VHqVrTfLhsKdM8djLWeFp7YRaWlNjQnoweHKBaBRL0HVkrwh/1fvtnlIB4K8kNc8liwCIOmpt0WMFkMKHBqeRJ/XS2gGQ==
EOF

    (ceph-dev)# bin/ceph dashboard sso setup saml2 https://cephdashboard.local  https://localhost:9443/idp/shibboleth uid https://cephdashboard/idp sp_x_509_cert sp_private_key | jq

> To generate a different certificate:
>
> `openssl req -new -x509 -days 3652 -nodes -out sp.crt -keyout saml.key`

Access `shibboleth` container:

    # docker-compose exec shibboleth /bin/bash

Add the following entry to shibboleth `/etc/hosts`:

    <your_ip> cephdashboard.local

Setup `shibboleth` IdP:

    (shibboleth)# curl https://cephdashboard.local/auth/saml2/metadata --output /opt/shibboleth-idp/metadata/cephdashboard-metadata.xml --insecure

    (shibboleth)# $JETTY_HOME/bin/jetty.sh restart

Login with user `admin` password `admin`.

> Note: SLO is not fully configured, yet

### Enabling HAProxy

For testing Ceph Dashboard HA you should run multiple Ceph Managers. To do so
execute the following command in your Ceph development environment:

    # export MGR=3
    # start-ceph.sh

Now you have to update the HAProxy configuration file `./haproxy/haproxy.conf`
and adapt the host ports of your running Ceph Dashboards. You will find them
in the output of the `vstart.sh` script. After that start the HAProxy:

    # docker-compose up haproxy

or if you want to enable all services:

    # docker-compose up haproxy alertmanager grafana node-exporter prometheus

Now you can reach the Ceph Dashboard via

    * http://localhost/
    * https://localhost/

To simulate a failover you have to find out which node is active. This can be
done by running:

    # ceph status

To force a failover you simply have to execute the following command on one of
your Ceph Manager nodes x, y or z:

    # ceph mgr fail <ACTIVE_MGR>
    # ceph mgr fail x

If you are logged into the Dashboard via HTTPS while a failover occurs, then
you will get error messages because of the changed SSL certificate of the new
active Ceph Dashboard instance. Please refresh the browser to fix this.

## Troubleshooting

### Permission error when trying to access `/ceph`

If you encounter a `permisson denied` when trying to access `/ceph` by, for
instance, running `setup-ceph.sh` or simply by trying to list its contents (to
verify that it has been mounted correctly), the chances are high that your host
system uses SELinux. To circumvent that problem, you can simply disable SELinux
by running:

    sudo setenforce permissive

This puts SELinux in permissive mode, where the rules are still evaluated but
not enforced, they are only logged. This basically *disables* SELinux, making
the host system more vulnerable for security flaws.
