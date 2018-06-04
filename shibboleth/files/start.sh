#!/bin/bash

httpd
shibd -f
$JETTY_HOME/bin/jetty.sh start
tail -f /opt/shibboleth-idp/logs/idp-process.log
