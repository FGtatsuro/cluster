#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# https://docs.python.org/3.5/howto/pyporting.html#prevent-compatibility-regressions
from __future__ import absolute_import
from __future__ import division
from __future__ import print_function

import subprocess
import sys

import daemon
import lockfile.pidlockfile

if __name__ == '__main__':
    stdout = open('{{ cluster_daemon_stdout_log }}', mode='a+')
    stderr = open('{{ cluster_daemon_stderr_log }}', mode='a+')
    pidfile = lockfile.pidlockfile.PIDLockFile('{{ cluster_daemon_pidfile }}')
    with daemon.DaemonContext(stdout=stdout, stderr=stderr, pidfile=pidfile):
        subprocess.call(['{{ cluster_service_dir }}/services.sh'] + sys.argv[1:])
