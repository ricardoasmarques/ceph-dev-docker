#compdef dash
#autoload

dash () {
  $1.sh
}

_dash() {
  local -a commands

  commands=(
    'build-frontend:Installs npm packages and builds the frontend.'
    'make-frontend:Removes all dashboard generated files and rebuilds it'
    'npm-start:Installs npm packages and starts angular dev server.'
    'reload-dashboard:Disable and enable the mgr module.'
    'setup-ceph:Installs deps and compiles ceph.'
    'setup-proxy:Updates "proxy.conf.json" with the current dashboard url.'
    'start-ceph:Starts a vstart cluster with RGW enabled.'
    'stop-ceph:Stops the vstart cluster.'
    'stop-ceph:Stops the vstart cluster.'
  )

  _describe -t commands 'dash command' commands && ret=0
}

compdef _dash dash

