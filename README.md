cluster
=======

[Consul](https://www.consul.io/docs/)/[Nomad](https://www.nomadproject.io/docs/) cluster
for other services. In our main usecases, other services as Docker containers are deployed
on the cluster.

Requirements
------------

The dependencies on other softwares/libraries for this service are as follows.

- Python (2.7.x)
- pip (>= 9.0.x)
- [Ansible](http://docs.ansible.com/ansible/index.html) (>= 2.2.x)
- [Ansible roles](./role_requirements.yml)

For tests/utility tasks, it's better to install following softwares/libraries.

- Ruby (>= 2.2.x)
- Rake (>= 11.x)

And this service also depends on [ansible_utility](https://github.com/FGtatsuro/ansible_utility) module.
In default, we assume that both this service/the module have same parent directory like this:

```
$ ls -1 services
...
ansible_utility
cluster
...
```

Please use `utility_module_path` variable(Describe later) on build phase if you want to put `ansible_utility` module to another place.

Build
-----

At first, please install libraries to build services.

```bash
$ pip install ansible
$ ansible-galaxy install -r role_requirements.yml
```

Before build, We must prepare the inventory including following groups.

- `consul-server`
- `consul-client`
- `nomad-server`
- `nomad-client`
- `cluster`

For example,

```bash
# Inventry for machines via ssh/local connection.
# In an inventry file, same hostname can't be used in different groups.
# Thus, several separate inventry files are needed.
$ cat tests/inventory/ssh/consul
[consul-server]
server  ansible_port=2227 ansible_ssh_private_key_file='.vagrant/machines/server/virtualbox/private_key'

[consul-client]
client  ansible_port=2228 ansible_ssh_private_key_file='.vagrant/machines/client/virtualbox/private_key'

[cluster:children]
consul-server
consul-client

[cluster:vars]
ansible_connection=ssh
ansible_user=vagrant
ansible_host=127.0.0.1
...

$ cat tests/inventory/ssh/nomad
[nomad-server]
server  ansible_port=2227 ansible_ssh_private_key_file='.vagrant/machines/server/virtualbox/private_key'

[nomad-client]
client  ansible_port=2228 ansible_ssh_private_key_file='.vagrant/machines/client/virtualbox/private_key'

[cluster:children]
nomad-server
nomad-client

[cluster:vars]
ansible_connection=ssh
ansible_user=vagrant
ansible_host=127.0.0.1
...
```

After that, we can build this service as follows.

```bash
# These inventory files are for testing. Please use your inventory files.
$ ansible-playbook provision/main.yml -i tests/inventory/ssh/consul -l cluster
$ ansible-playbook provision/main.yml -i tests/inventory/ssh/nomad -l cluster
```

### Variables

This service uses several role variables with service-specified values.

|name|description|default value|
|---|---|---|
|utility_module_path|Path `ansible_utility` module exists. You can use absolute path or relative path from `./provision/main.yml`.|../../ansible_utility|
|consul_config_src_dir|`consul_config_src_dir` of [FGtatsuro.consul](https://github.com/FGtatsuro/ansible-consul#common).|../resources/consul/consul.d/|
|consul_default_config_server|`consul_default_config_server` of [FGtatsuro.consul](https://github.com/FGtatsuro/ansible-consul#common).|true(only on `consul-server`)|
|consul_default_config_dns_port|`consul_default_config_dns_port` of [FGtatsuro.consul](https://github.com/FGtatsuro/ansible-consul#common).|53|
|consul_daemon_cap_net_bind|`consul_daemon_cap_net_bind` of [FGtatsuro.consul](https://github.com/FGtatsuro/ansible-consul#only-linux).|true|
|nomad_config_src_dir|`nomad_config_src_dir` of [FGtatsuro.nomad](https://github.com/FGtatsuro/ansible-nomad#common).|../resources/nomad/nomad.d/server (on `nomad-server`)<br>../resources/nomad/nomad.d/client (on `nomad-client`)|
|nomad_default_config_server_enabled|`nomad_default_config_server_enabled` of [FGtatsuro.nomad](https://github.com/FGtatsuro/ansible-nomad#common).|true(only on `nomad-server`)|
|nomad_default_config_client_enabled|`nomad_default_config_client_enabled` of [FGtatsuro.nomad](https://github.com/FGtatsuro/ansible-nomad#common).|true(only on `nomad-client`)|
|docker_install_machine|`docker_install_machine` of [FGtatsuro.docker_toolbox](https://github.com/FGtatsuro/ansible-docker-toolbox#only-linux).|no|
|docker_install_compose|`docker_install_compose` of [FGtatsuro.docker_toolbox](https://github.com/FGtatsuro/ansible-docker-toolbox#only-linux).|no|

- If you want to use other role variables, please check READMEs of following Ansible roles this service depends on.
  - [FGtatsuro.consul](https://github.com/FGtatsuro/ansible-consul)
  - [FGtatsuro.nomad](https://github.com/FGtatsuro/ansible-nomad)
  - [FGtatsuro.docker_toolbox](https://github.com/FGtatsuro/ansible-docker-toolbox)
- If you want to overwrite these variables, it's easy to set them via Ansible [--extra-vars](http://docs.ansible.com/ansible/playbooks_variables.html#passing-variables-on-the-command-line) option.

Deploy
------

After build, we can start/stop this service as follows.

```bash
# These inventory files are for testing. Please use your inventory files.
# Start cluster
$ ansible-playbook deploy/ssh/start_cluster.yml -i tests/inventory/ssh/consul -l cluster
$ ansible-playbook deploy/ssh/start_cluster.yml -i tests/inventory/ssh/nomad -l cluster

# Stop cluster
$ ansible-playbook deploy/ssh/stop_cluster.yml -i tests/inventory/ssh/nomad -l cluster
$ ansible-playbook deploy/ssh/stop_cluster.yml -i tests/inventory/ssh/consul -l cluster
```

### Variables

There are variables related to the playbook to start service(=`start_cluster.yml`).

|name|description|default value|
|---|---|---|
|consul_daemon_script_dir|`consul_daemon_script_dir` of [FGtatsuro.consul](https://github.com/FGtatsuro/ansible-consul#only-not-container).|/opt/consul|
|consul_owner|`consul_owner` of [FGtatsuro.consul](https://github.com/FGtatsuro/ansible-consul#common).>If this value isn't `root` and `consul_daemon_root_privilege` is false, Consul daemon is started by `consul_owner`.|consul|
|consul_daemon_root_privilege|If this value is true, Consul daemon is started by root.|false|
|nomad_daemon_script_dir|`nomad_daemon_script_dir` of [FGtatsuro.nomad](https://github.com/FGtatsuro/ansible-nomad#only-not-container).|/opt/nomad|
|nomad_owner|`nomad_owner` of [FGtatsuro.nomad](https://github.com/FGtatsuro/ansible-nomad#common).<br>If this value isn't `root` and `nomad_daemon_root_privilege` is false, Nomad daemon is started by `nomad_owner`.|nomad|
|nomad_daemon_root_privilege|If this value is true, Nomad daemon is started by root.|false|

Test
----

At first, please install libraries to test this service.

```bash
$ pip install ansible
$ ansible-galaxy install -r role_requirements.yml
$ ansible-galaxy install -r tests/role_requirements.yml
$ ansible-playbook tests/setup_cluster.yml -l localhost
$ gem install bundler
$ bundle install --path vendor/bundle
```

After that, please create containers for test, and run tests on them.

```bash
$ ansible-playbook provision/main.yml -i tests/inventory/docker/hosts -l cluster
$ bundle exec rake cluster:spec:all
```

Test on Vagrant VMs
-------------------

To confirm the behavior of this service on cluster consisting of multiple machines, we run tests on Vagrant VMs.

At first, please install libraries to test this service.

```bash
$ pip install ansible
$ ansible-galaxy install -r role_requirements.yml
$ ansible-galaxy install -r tests/role_requirements.yml
$ ansible-playbook tests/setup_cluster.yml -l localhost
$ gem install bundler
$ bundle install --path vendor/bundle
```

After that, please create VMs for test, and run tests on them.

```bash
$ vagrant up
$ ansible-playbook provision/main.yml -i tests/inventory/ssh/consul -l cluster
$ ansible-playbook provision/main.yml -i tests/inventory/ssh/nomad -l cluster
$ ansible-playbook deploy/ssh/start_cluster.yml -i tests/inventory/ssh/consul -l cluster
$ ansible-playbook deploy/ssh/start_cluster.yml -i tests/inventory/ssh/nomad -l cluster
$ ansible-playbook tests/start_job.yml -i tests/inventory/ssh/nomad -l server
#
# Wait a minute. Submitting jobs takes a few time.
#
$ bundle install --path vendor/bundle
$ bundle exec rake cluster:spec:server
$ bundle exec rake cluster:spec:client
```

Limitation
----------

Now, containers of this service can't work well. Thus, it's only valid for testing to check provisioning.

- On OSX(Docker for Mac), network issue exists. (Ref. https://forums.docker.com/t/should-docker-run-net-host-work/14215/21)
- On Linux, Consul/Nomad processes run, but submitting jobs is failed.
