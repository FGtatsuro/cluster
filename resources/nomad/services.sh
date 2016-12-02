#!/bin/bash

NOMAD_DATADIR=${CONSUL_DATADIR:-/tmp/nomad}
NOMAD_CONFIGDIR=${NOMAD_CONFIGDIR:-/etc/nomad.d}

# Rewrite Consul settings.
# This is a workaround because hcl doesn't support interpolation of environment variable.
# Ref. https://github.com/hashicorp/nomad/issues/918
# Ref. https://github.com/hashicorp/hcl/issues/81
NOMAD_CONSUL_HTTP_ADDRESS=${NOMAD_CONSUL_HTTP_ADDRESS:-127.0.0.1:8500}
NOMAD_CONSUL_CONFIG=${NOMAD_CONSUL_CONFIG:-${NOMAD_CONFIGDIR}/consul.hcl}
sed -i'' -e "s/REPLACE_NOMAD_CONSUL_HTTP_ADDRESS/${NOMAD_CONSUL_HTTP_ADDRESS}/g" ${NOMAD_CONSUL_CONFIG}

OPTS="-bind=${NOMAD_BIND_ADDRESS} -data-dir=${NOMAD_DATADIR} -config=${NOMAD_CONFIGDIR} "
if [ "$1" == "server" ]
then
    OPTS="${OPTS} -server -bootstrap-expect=${NOMAD_SERVER_NUM}"
else
    OPTS="${OPTS} -client"
fi
nomad agent ${OPTS}
