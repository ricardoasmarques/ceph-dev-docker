Steps to setup Grafana Dashboard for embedding:-
In a working directory:-
1. `git clone https://github.com/ceph/ceph.git`
2. `git clone https://github.com/ricardoasmarques/ceph-dev-docker.git`

After build and setting up docker for ceph.
1. To bring node-exporter, prometheus and Grafana services up `docker-compose up`

Once all the services are up
1. Login to `localhost:3000` (admin/admin)
2. Add prometheus as data source
3. Import json files one by one by clicking `+` on left Dashboard

Now
1. Inside `ceph-dev` container, start ceph instance using `start-ceph.sh`
2. Navigation to build directory `cd /ceph/build`
3. Enable prometheus Module `./bin/ceph mgr module enable prometheus`
4. Start web-server at 4200 `npm-start.sh` (this is required because Grafana dashboard doesnt run on https)

Plugins required for grafana are :-
1. https://grafana.com/plugins/grafana-piechart-panel
2. https://grafana.com/plugins/vonage-status-panel
