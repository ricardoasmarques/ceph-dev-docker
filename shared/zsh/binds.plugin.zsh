#compdef binds
#autoload

npm () {
  DIR=$(pwd)
  source /ceph/build/src/pybind/mgr/dashboard/node-env/bin/activate .
  cd /ceph/src/pybind/mgr/dashboard/frontend
  command npm $@
  deactivate
  cd $DIR
}

npx () {
  DIR=$(pwd)
  source /ceph/build/src/pybind/mgr/dashboard/node-env/bin/activate .
  cd /ceph/src/pybind/mgr/dashboard/frontend
  command npx $@
  deactivate
  cd $DIR
}

ceph () {
  DIR=$(pwd)
  cd /ceph/build
  bin/ceph $@
  cd $DIR
}
