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
- Docker (>= 1.13.1)
- Docker Compose (1.9.x)

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

Before build, We must prepare the inventory including `consul`, `nomad` and `cluster` group. For example,

```bash
# Inventry for machines via ssh/local connection.
# In an inventry file, same hostname can't be used in different groups.
# Thus, two separate inventry files are needed.
$ cat spec/inventory/ssh/consul
[consul]
localhost ansible_connection=local
192.168.1.11  ansible_connection=ssh ansible_user=clusteruser

[cluster:children]
consul
...

$ cat spec/inventory/ssh/nomad
[nomad]
localhost ansible_connection=local
192.168.1.11  ansible_connection=ssh ansible_user=clusteruser

[cluster:children]
nomad
...


# Inventry for containers
$ cat spec/inventory/docker/hosts
[consul]
service-cluster-consul          utility_docker_base_image=fgtatsuro/infra-bridgehead:alpine-3.3 utility_docker_commit_image=fgtatsuro/consul:0.1

[nomad]
service-cluster-nomad           utility_docker_base_image=fgtatsuro/infra-bridgehead:debian-jessie utility_docker_commit_image=fgtatsuro/nomad:0.1

[cluster:children]
consul
nomad
...
```

After that, we can build this service as follows.

```bash
# Machine via ssh/local connection
$ ansible-playbook provision/main.yml -i spec/inventory/pm/hosts -l cluster

# Container
$ ansible-playbook provision/main.yml -i spec/inventory/docker/hosts -l cluster
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

### Container

**ATTENTION**: Containers of this service can't work well. Please check [limitation section](#Limitation).

After build, we can start/stop them as follows.

```bash
# You must set specified environment variables before server starts. (Describe later)
# Start server
(server) $ (cd deploy/docker/server/ && docker-compose up -d)
# Stop server
(server) $ (cd deploy/docker/server/ && docker-compose down)

# You must set specified environment variables before client starts. (Describe later)
# Start client
(client) $ (cd deploy/docker/client/ && docker-compose up -d)
# Stop client
(client) $ (cd deploy/docker/client/ && docker-compose down)
```

And helper tasks are defined to start/stop this service with environment variables.

```bash
# Start server
$ bundle exec rake cluster:container:start-server[cluster-server-01,10.0.0.212]
# Stop server
$ bundle exec rake cluster:container:stop-server
```

Test
----

At first, please install libraries to test this service.

```bash
$ pip install ansible
$ ansible-galaxy install -r role_requirements.yml
$ gem install bundler
$ bundle install
```

After that, please create containers for test, and run tests on them.

```bash
$ ansible-playbook provision/main.yml -i spec/inventory/docker/hosts -l cluster
$ bundle exec rake cluster:spec:all
```

Task
----

As we use tasks to deploy service/run tests, several utility tasks are defined. You can check them with `bundle exec rake -D`.

Limitation
----------

Now, containers of this service can't work well. Thus, it's only valid for testing to check provisioning.

- On OSX(Docker for Mac), network issue exists. (Ref. https://forums.docker.com/t/should-docker-run-net-host-work/14215/21)
- On Linux, Consul/Nomad processes run, but submitting jobs is failed.
