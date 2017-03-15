require "spec_helper_#{ENV['TARGET_BACKEND']}"

describe file("/etc/nomad.d/nomad_common.json") do
  its(:content) { should match /server {\n(.*\n){0,2}  enabled = true/ }
  its(:content) { should_not match /client {\n(.*\n){0,2}  enabled =/ }
end

describe command('which docker') do
  its(:exit_status) { should_not eq 0 }
end
