#!/bin/bash

set -e

refresh=0

for i in "$@"; do
    case $i in
    --refresh)
        refresh=1
    ;;
    esac
done

# Make sure the host SSH directory is mapped into the Docker container.
if [ ! -e "/root/.ssh/id_rsa" -o ! -e "/root/.ssh/id_rsa.pub" ]; then
    echo "ERROR: The host SSH directory is not mapped into the Docker container. Make sure to use the command line argument '-v ~/.ssh:/root/.ssh:ro' when starting the Docker container."
    exit 1
fi

# Make sure the SSH configuration of the Vagrant box is available.
if [ ! -e "/ceph/src/pybind/mgr/cephadm/ssh-config" ]; then
    echo "ERROR: No ssh-config file found. Make sure to run 'vagrant ssh-config > ssh-config' in the directory 'src/pybind/mgr/cephadm' of your host system."
    exit 1
fi

cd /ceph/build

bin/ceph config-key set mgr/cephadm/ssh_identity_key -i /root/.ssh/id_rsa
bin/ceph config-key set mgr/cephadm/ssh_identity_pub -i /root/.ssh/id_rsa.pub

bin/ceph mgr module enable cephadm
bin/ceph orch set backend cephadm
bin/ceph orch status

bin/ceph cephadm set-ssh-config -i /ceph/src/pybind/mgr/cephadm/ssh-config

# Remove previous Vagrant box nodes from /etc/hosts.
# http://blog.jonathanargentiero.com/docker-sed-cannot-rename-etcsedl8ysxl-device-or-resource-busy/
sed --regexp-extended '/(osd|mgr|mon)0$/d' /etc/hosts > /root/hosts.new
cp -f /root/hosts.new /etc/hosts

# Add the IP addresses of the Vagrant box nodes to the containers /etc/hosts file.
pip install paramiko
python3 <<EOS
import paramiko
config = paramiko.SSHConfig()
config.parse(open('/ceph/src/pybind/mgr/cephadm/ssh-config'))
with open('/etc/hosts', 'a') as f:
    for hostname in ['osd0', 'mgr0', 'mon0']:
        host_config = config.lookup(hostname)
        f.write('{} {}\n'.format(host_config.get('hostname'), hostname))
EOS

bin/ceph orch host add mgr0
bin/ceph orch host add mon0
bin/ceph orch host add osd0

if [ "$refresh" -eq 1 ]; then
    echo "Refreshing device list, please wait ..."
    bin/ceph orch device ls --refresh
fi
