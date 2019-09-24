#
# Cookbook:: qbrd-sysprep
# Recipe:: default
#
# The MIT License (MIT)
#
# Copyright:: 2019, QubitRenegade
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

package node['qbrd-sysprep']['packages'].select { |_k, v| v }.map { |k, _v| k } do
  action :install
end

service 'rsyslog' do
  action :stop
end

service 'auditd' do
  action :stop
end

case node['platform']
when 'centos', 'redhat', 'scientific', 'oracle'
  bash 'cleanup script' do
    action :run
    code <<~EO_CLEANUP_SCRIPT
      #!/usr/bin/env bash
      set -x

      # Step 2: Clean out yum.
      /usr/bin/yum clean all

      # Step 3: Force the logs to rotate & remove old logs we don’t need.
      /usr/sbin/logrotate –f /etc/logrotate.conf
      /bin/rm -vf /var/log/*-???????? /var/log/*.gz
      /bin/rm -vf /var/log/dmesg.old
      /bin/rm -vrf /var/log/anaconda

      # Step 4: Truncate the audit logs (and other logs we want to keep placeholders for).
      /bin/cat /dev/null > /var/log/audit/audit.log
      /bin/cat /dev/null > /var/log/wtmp
      /bin/cat /dev/null > /var/log/lastlog
      /bin/cat /dev/null > /var/log/grubby

      # Step 5: Remove the udev persistent device rules.
      /bin/rm -vf /etc/udev/rules.d/70*

      # Step 6: Remove the traces of the template MAC address and UUIDs.
      /bin/sed -i '/^(HWADDR|UUID)=/d' /etc/sysconfig/network-scripts/ifcfg-eth0

      # Step 7: Clean /tmp out.
      /bin/rm -vrf /tmp/*
      /bin/rm -vrf /var/tmp/*

      # Step 8: Remove the SSH host keys.
      /bin/rm -vf /etc/ssh/*key*

      # Step 9: Remove the root user’s shell history.
      /bin/rm -f ~root/.bash_history
      unset HISTFILE

      # Step 10: Remove the root user’s SSH history & other cruft.
      /bin/rm -rf ~root/.ssh/
      /bin/rm -f ~root/anaconda-ks.cfg
    EO_CLEANUP_SCRIPT
  end
when 'ubuntu'
  bash 'cleanup script' do
    action :run
    code <<~EO_CLEANUP_SCRIPT
      set -x

      echo "This is the ubuntu Version"
    EO_CLEANUP_SCRIPT
  end
end

bash 'cleanup hab dir' do
  action :run
  code <<~GOODBYE_CRUEL_WORLD
    set -x
    rm -rf /hab
  GOODBYE_CRUEL_WORLD
end
