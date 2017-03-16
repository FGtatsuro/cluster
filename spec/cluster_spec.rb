require "spec_helper_#{ENV['TARGET_BACKEND']}"

# {
#   "consul": [],
#   "global-redis-check": [
#     "global",
#     "cache"
#   ],
#   "nomad": [
#     "rpc",
#     "serf",
#     "http"
#   ],
#   "nomad-client": [
#     "http"
#   ]
# }
describe command("curl #{ENV['NOMAD_CONSUL_ADDRESS']}/v1/catalog/services") do
  its(:exit_status) { should eq 0 }
  its(:stdout_as_json) { should include('consul' => eq([])) }
  its(:stdout_as_json) { should include('nomad-client' => eq(['http'])) }
  its(:stdout_as_json) { should include('global-redis-check' => include('global')) }
  its(:stdout_as_json) { should include('global-redis-check' => include('cache')) }
  its(:stdout_as_json) { should include('nomad' => include('rpc')) }
  its(:stdout_as_json) { should include('nomad' => include('serf')) }
  its(:stdout_as_json) { should include('nomad' => include('http')) }
end
