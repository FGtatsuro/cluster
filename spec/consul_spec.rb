require "spec_helper_#{ENV['TARGET_BACKEND']}"

describe file('/etc/consul.d') do
    it { should be_directory }
    it { should be_readable }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
end

describe file('/opt/consul/services.sh') do
    it { should be_file }
    it { should be_mode 755 }
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
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
