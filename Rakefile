require 'rake'
require 'rspec/core/rake_task'

namespace :cluster do
  namespace :spec do
    hosts = [
      {
        :name     =>  'service-cluster-consul-server',
        :backend  =>  'docker',
        :pattern  =>  'consul_server_spec.rb'
      },
      {
        :name     =>  'service-cluster-consul-client',
        :backend  =>  'docker',
        :pattern  =>  'consul_client_spec.rb'
      },
      {
        :name     =>  'service-cluster-nomad-server',
        :backend  =>  'docker',
        :pattern  =>  'nomad_server_spec.rb'
      },
      {
        :name     =>  'service-cluster-nomad-client',
        :backend  =>  'docker',
        :pattern  =>  'nomad_client_spec.rb'
      },
      {
        :name =>  'server',
        :backend  =>  'vagrant',
        :nomad_consul_address => '192.168.50.6:8500',
        :pattern  =>  'consul_server_spec.rb,nomad_server_spec.rb,cluster_spec.rb'
      },
      {
        :name =>  'client',
        :backend  =>  'vagrant',
        :nomad_consul_address => '192.168.50.7:8500',
        :pattern  =>  'consul_client_spec.rb,nomad_client_spec.rb,cluster_spec.rb'
      }
    ]

    all = []

    hosts.each do |host|
      n = host[:name].gsub(/service-cluster-/, '')
      desc "Run serverspec tests for #{n}."
      RSpec::Core::RakeTask.new(n.to_sym) do |t|
        ENV['TARGET_HOST'] = host[:name]
        ENV['TARGET_BACKEND'] = ENV['TARGET_BACKEND'] || host[:backend]
        ENV['NOMAD_CONSUL_ADDRESS'] = host[:nomad_consul_address]
        t.pattern = host[:pattern]
      end
      all << "cluster:spec:#{n}"
    end

    desc 'Run serverspec tests.'
    task :all     => all
  end
end
