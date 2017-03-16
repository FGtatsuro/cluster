require "spec_helper_#{ENV['TARGET_BACKEND']}"

describe file("/etc/nomad.d/nomad_common.hcl") do
  its(:content) { should_not match /server {\n(.*\n){0,2}  enabled =/ }
  its(:content) { should match /client {\n(.*\n){0,2}  enabled = true/ }
end

describe file("/etc/nomad.d/docker.hcl") do
  its(:content) { should match /"docker.cleanup.image" = "false"/ }
end

describe command('which docker') do
  its(:exit_status) { should eq 0 }
end

describe command('which docker-compose') do
  its(:exit_status) { should_not eq 0 }
end

describe command('which docker-machine') do
  its(:exit_status) { should_not eq 0 }
end
