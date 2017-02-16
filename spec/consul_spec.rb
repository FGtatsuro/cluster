require "spec_helper_#{ENV['TARGET_BACKEND']}"

[
  '/etc/consul.d',
  '/var/log/cluster',
  '/var/lock/cluster'
].each do |f|
  describe file(f) do
    it { should be_directory }
    it { should be_readable }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end
end

[
  '/opt/cluster/consul/services.sh',
  '/opt/cluster/consul/daemons.py'
].each do |f|
  describe file(f) do
    it { should be_file }
    it { should be_mode 755 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end
end

# Add specs if configs are added.
[
].each do |f|
  describe file(f) do
    it { should be_file }
    it { should be_readable }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
  end
end
