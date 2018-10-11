#!/bin/bash

set -e

setup-proxy.sh

cdsdf
source $SDP/node-env/bin/activate
npm i

npm start
