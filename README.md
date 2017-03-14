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
# This inventory file is for testing. Please use your inventory file.
$ ansible-playbook provision/main.yml -i tests/inventory/ssh/consul -l cluster
$ ansible-playbook provision/main.yml -i tests/inventory/ssh/nomad -l cluster
```

### Variables

These are Ansible variables related to build process.
If you want to use not-default values, it's easy to set them via Ansible [--extra-vars](http://docs.ansible.com/ansible/playbooks_variables.html#passing-variables-on-the-command-line) option.

|name|description|default value|
|---|---|---|
|utility_module_path|Path `ansible_utility` module exists. You can use absolute path or relative path from `./provision/main.yml`.|../../ansible_utility|

Config
------

We can put additional configs of Consul/Nomad. Config files under following directories are deployed.

- [./resources/consul/consul.d/ (Consul config directory)](./resources/consul/consul.d/)
- [./resources/nomad/nomad.d/ (Nomad config directory)](./resources/nomad/nomad.d/)

This step must be done before build.

Deploy
------

This service can be deployed as both server and client.

### Machine via ssh/local connection

After build, we can start/stop them as follows.

```bash
# You must set specified environment variables before server starts. (Describe later)
# Start server
(server) $ sudo -E /opt/cluster/consul/daemons.py server
(server) $ sudo -E /opt/cluster/nomad/daemons.py server
# Stop server (TODO: more graceful way)
(server) $ sudo pkill -f "consul"
(server) $ sudo pkill -f "nomad"

# You must set specified environment variables before client starts. (Describe later)
# Start client
(client) $ sudo -E /opt/cluster/consul/daemons.py client
(client) $ sudo -E /opt/cluster/nomad/daemons.py client
# Stop client (TODO: more graceful way)
(client) $ sudo pkill -f "consul"
(client) $ sudo pkill -f "nomad"
```

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
$ ansible-playbook tests/run_cluster.yml -i tests/inventory/ssh/consul -l cluster
$ ansible-playbook tests/run_cluster.yml -i tests/inventory/ssh/nomad -l cluster
$ ansible-playbook tests/run_job.yml -i tests/inventory/ssh/nomad -l server
#
# Wait a minute. Submitting jobs takes a few time.
#
```

Task
----

As we use tasks to deploy service/run tests, several utility tasks are defined. You can check them with `bundle exec rake -D`.

Limitation
----------

Now, containers of this service can't work well. Thus, it's only valid for testing to check provisioning.

- On OSX(Docker for Mac), network issue exists. (Ref. https://forums.docker.com/t/should-docker-run-net-host-work/14215/21)
- On Linux, Consul/Nomad processes run, but submitting jobs is failed.
