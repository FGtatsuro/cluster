require 'rake'
require 'rspec/core/rake_task'

namespace :cluster do
  namespace :spec do
    hosts = [
      {
        :name     =>  'service-cluster-consul',
        :backend  =>  'docker',
        :pattern  =>  'consul_spec.rb'
      },
      {
        :name     =>  'service-cluster-nomad',
        :backend  =>  'docker',
        :pattern  =>  'nomad_spec.rb'
      }
    ]

    all = []

    hosts.each do |host|
      n = host[:name].gsub(/service-/, '')
      desc "Run serverspec tests for #{n}."
      RSpec::Core::RakeTask.new(n.to_sym) do |t|
        ENV['TARGET_HOST'] = host[:name]
        ENV['TARGET_BACKEND'] = ENV['TARGET_BACKEND'] || host[:backend]
        t.pattern = host[:pattern]
      end
      all << "cluster:spec:#{n}"
    end

    desc 'Run serverspec tests.'
    task :all     => all
  end

  def _build(inventory, limitation, extra_vars, with_sudo)
    command =
      "cd #{File.expand_path(__dir__)} && " +
      "ansible-playbook provision/main.yml " +
      "-i #{inventory} -l #{limitation}"
    if extra_vars != nil then
      command = "#{command} -e #{extra_vars}"
    end
    if with_sudo then
      command = "#{command} -K"
    end
    sh command
  end

  namespace :ssh do
    desc "Build clusters on machines via ssh/local connection. :consul_inventory/:nomad_inventory accept absolute path or relative path of the directory this Rakefile exists.\n" +
      "Default: :limitation=cluster, :extra_vars=nil"
    task 'build', :consul_inventory, :nomad_inventory, :limitation, :extra_vars do |t, args|
      args.with_defaults(
        :limitation => 'cluster',
        :extra_vars => nil
      )
      _build(args[:consul_inventory], args[:limitation], args[:extra_vars], true)
      _build(args[:nomad_inventory], args[:limitation], args[:extra_vars], true)
    end
  end
end
