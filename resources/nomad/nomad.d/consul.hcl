/*
ATTENTION: This doesn't work without service script.
It rewrites this config with environment variable 'NOMAD_CONSUL_HTTP_ADDRESS'.
This is a workaround because hcl doesn't support interpolation of environment variable.
Ref. https://github.com/hashicorp/nomad/issues/918
Ref. https://github.com/hashicorp/hcl/issues/81
*/
consul {
  address = "REPLACE_NOMAD_CONSUL_HTTP_ADDRESS"
}
