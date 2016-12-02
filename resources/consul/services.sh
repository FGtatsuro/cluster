#!/bin/bash

CONSUL_DATADIR=${CONSUL_DATADIR:-/tmp/consul}
CONSUL_CONFIGDIR=${CONSUL_CONFIGDIR:-/etc/consul.d}
OPTS="-node=${CONSUL_NODE_NAME} -bind=${CONSUL_BIND_ADDRESS} -client=${CONSUL_BIND_ADDRESS} -data-dir=${CONSUL_DATADIR} -config-dir=${CONSUL_CONFIGDIR}"
if [ "$1" == "server" ]
then
    OPTS="${OPTS} -server -bootstrap-expect=${CONSUL_SERVER_NUM}"
fi
if [ -n "${CONSUL_JOIN_ADDRESS}" ]
then
    OPTS="${OPTS} -join=${CONSUL_JOIN_ADDRESS}"
fi

consul agent ${OPTS}
