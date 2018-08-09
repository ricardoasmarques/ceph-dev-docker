# Source this to have some usefull shortcuts

function ceph-reset {
    stop-ceph.sh
    start-ceph.sh
}

function cd-lint-python {
    cdsd
    tox -e lint
    cd -
}

function cd-unit-tests {
    cdsd
    tox
    cd -
}

function cd-traceback {
    reload-dashboard.sh
    traceback-mgr
}

function cd-debug {
    reload-dashboard.sh
    tail -f /ceph/build/out/mgr.x.log | grep --line-buffered "\[dashboard\] [^N]"
}

function traceback-mgr {
    grep -A 30 -B 30 "Traceback" /ceph/build/out/mgr.x.log
    tail -f /ceph/build/out/mgr.x.log | grep --line-buffered -A 30 -B 30 "Traceback"
}

function debug-mgr {
    tail -f /ceph/build/out/mgr.x.log | grep --line-buffered "\[py\] [^N]"
}

