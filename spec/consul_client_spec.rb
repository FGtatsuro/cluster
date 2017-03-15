require "spec_helper_#{ENV['TARGET_BACKEND']}"

describe file("/etc/consul.d/consul_common.json") do
  its(:content) { should match /"ports": {"dns": 53 }/ }
  its(:content) { should_not match /"server": true/ }
end

describe command('getcap /usr/local/bin/consul') do
  its(:exit_status) { should eq 0 }
  its(:stdout) { should match /#{Regexp.escape('/usr/local/bin/consul = cap_net_bind_service+ep')}/ }
end
