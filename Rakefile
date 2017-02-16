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

  namespace :container do
    def cluster_server_start_cmd(node_name, bind_address, join_address, server_num)
      num = server_num || 3
      join = join_address
      if join == 'nil' then
        join = nil
      end
      env = [
        "CONSUL_NODE_NAME=#{node_name}",
        "CONSUL_BIND_ADDRESS=#{bind_address}",
        "CONSUL_SERVER_NUM=#{num}",
        "NOMAD_BIND_ADDRESS=#{bind_address}",
        "NOMAD_CONSUL_HTTP_ADDRESS=#{bind_address}:8500",
        "NOMAD_SERVER_NUM=#{num}"
      ]
      if join then
        env << "CONSUL_JOIN_ADDRESS=#{join}"
      end
      command = "#{env.join(' ')} docker-compose up -d"
      return command
    end

    def cluster_client_start_cmd(node_name, bind_address, join_address)
      env = [
        "CONSUL_NODE_NAME=#{node_name}",
        "CONSUL_BIND_ADDRESS=#{bind_address}",
        "CONSUL_JOIN_ADDRESS=#{join_address}",
        "NOMAD_BIND_ADDRESS=#{bind_address}",
        "NOMAD_CONSUL_HTTP_ADDRESS=#{bind_address}:8500"
      ]
      command = "#{env.join(' ')} docker-compose up -d"
      return command
    end

    def cluster_server_stop_cmd
      env = [
        "CONSUL_BIND_ADDRESS=''",
        "NOMAD_BIND_ADDRESS=''"
      ]
      command = "#{env.join(' ')} docker-compose down"
      return command
    end

    def cluster_clientr_stop_cmd
      env = [
        "CONSUL_BIND_ADDRESS=''",
        "NOMAD_BIND_ADDRESS=''"
      ]
      command = "#{env.join(' ')} docker-compose down"
      return command
    end

    def cluster_images_push_cmd(repo_url, images)
      command =
        images.map{|image|
        "docker tag #{image} #{repo_url}/#{image} && " +
        "docker push #{repo_url}/#{image} && " +
        "docker rmi -f #{repo_url}/#{image}"
      }.join(' && ')
        return command
    end

    def cluster_images_pull_cmd(repo_url, images)
      command =
        images.map{|image|
        "docker pull #{repo_url}/#{image} && " +
        "docker tag #{repo_url}/#{image} #{image} && " +
        "docker rmi -f #{repo_url}/#{image}"
      }.join(' && ')
        return command
    end

    # This is useful when we want to start servers via Ansible
    desc "Generate start-server command. Please set :join_address=nil if you want to pass :server_num, but doesn't want to pass :join_addrss.\n" +
      "This is useful when we want to start servers via Ansible."
    task 'gen-start-server-cmd', :node_name, :bind_address, :join_address, :server_num do |t, args|
      puts cluster_server_start_cmd(args[:node_name], args[:bind_address], args[:join_address], args[:server_num])
    end

    desc "Start server. Please set :join_address=nil if you want to pass :server_num, but doesn't want to pass :join_addrss.\n"
    task 'start-server', :node_name, :bind_address, :join_address, :server_num do |t, args|
      # Ref. http://route477.net/d/?date=20140219
      command =
        "cd #{File.expand_path(__dir__)}/deploy/docker/server/ && " +
        cluster_server_start_cmd(args[:node_name], args[:bind_address], args[:join_address], args[:server_num])
      sh command
    end

    desc "Generate stop-server command.\n" +
      "This is useful when we want to stop servers via Ansible."
    task 'gen-stop-server-cmd' do
      puts cluster_server_stop_cmd
    end

    desc 'Stop server.'
    task 'stop-server' do
      command =
        "cd #{File.expand_path(__dir__)}/deploy/docker/server/ && " +
        cluster_server_stop_cmd
      sh command
    end

    desc "Generate start-client command.\n" +
      "This is useful when we want to start clients via Ansible."
    task 'gen-start-client-cmd', :node_name, :bind_address, :join_address do |t, args|
      puts cluster_client_start_cmd(args[:node_name], args[:bind_address], args[:join_address])
    end

    desc "Start client.\n"
    task 'start-client', :node_name, :bind_address, :join_address do |t, args|
      command =
        "cd #{File.expand_path(__dir__)}/deploy/docker/client/ && " +
        cluster_client_start_cmd(args[:node_name], args[:bind_address], args[:join_address])
      sh command
    end

    desc "Generate stop-client command.\n" +
      "This is useful when we want to stop clients via Ansible."
    task 'gen-stop-client-cmd' do
      puts cluster_clientr_stop_cmd
    end

    desc 'Stop client.'
    task 'stop-client' do
      command =
        "cd #{File.expand_path(__dir__)}/deploy/docker/client/ && " +
        cluster_clientr_stop_cmd
      sh command
    end

    desc "Build cluster images on localhost. :inventory accepts absolute path or relative path of the directory this Rakefile exists.\n" +
      "Default: :inventory=spec/inventory/docker/hosts, :limitation=cluster, :extra_vars=nil"
    task 'build', :inventory, :limitation, :extra_vars do |t, args|
      args.with_defaults(
        :inventory => 'spec/inventory/docker/hosts',
        :limitation => 'cluster',
        :extra_vars => nil
      )
      _build(args[:inventory], args[:limitation], args[:extra_vars], false)
    end

    desc "Push cluster images to container registry. Before this task, container registry must run on :repo_url.\n" +
      "Default: repo_url=localhost:5000"
    task 'push', :repo_url do |t, args|
      args.with_defaults(:repo_url => 'localhost:5000')
      command = cluster_images_push_cmd(
        args[:repo_url],
        ['fgtatsuro/consul:0.1', 'fgtatsuro/nomad:0.1'])
      sh command
    end

    desc "Pull cluster images from container registry. Before this task, container registry must run on :repo_url.\n" +
      "Default: repo_url=localhost:5000"
    task 'pull', :repo_url do |t, args|
      args.with_defaults(:repo_url => 'localhost:5000')
      command = cluster_images_pull_cmd(
        args[:repo_url],
        ['fgtatsuro/consul:0.1', 'fgtatsuro/nomad:0.1'])
      sh command
    end

    desc "Generate pull command.\n" +
      "This is useful when we want to start servers via Ansible." +
      "Default: repo_url=localhost:5000"
    task 'gen-pull-cmd', :repo_url do |t, args|
      args.with_defaults(:repo_url => 'localhost:5000')
      command = cluster_images_pull_cmd(
        args[:repo_url],
        ['fgtatsuro/consul:0.1', 'fgtatsuro/nomad:0.1'])
      puts command
    end
  end
end
