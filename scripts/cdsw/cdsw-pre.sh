#!/bin/bash

set -x
exec > ~/bootstrap-cdsw.log 2>&1

curl -o /etc/yum.repos.d//cloudera-cdsw.repo http://archive.cloudera.com/cdsw/1/redhat/7/x86_64/cdsw/cloudera-cdsw.repo
yum -y install cloudera-data-science-workbench-1.1.0

echo bridge >> /etc/modules-load.d/bridge.conf
echo br_netfilter >> /etc/modules-load.d/br_netfilter.conf
modprobe br_netfilter

# disable now to be picked up after restart
sed -e 's/^SELINUX=enforcing/SELINUX=disabled/' -i /etc/selinux/config
sed -e 's/^SELINUX=permissive/SELINUX=disabled/' -i /etc/selinux/config

domain=cloudera.internal
ip=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)

# CDSW settings
sed -i "/MASTER_IP=/cMASTER_IP=\"${ip}\"" /etc/cdsw/config/cdsw.conf
sed -i "/JAVA_HOME=/cJAVA_HOME=\"/usr/java/default\"" /etc/cdsw/config/cdsw.conf

# Ensure that the hard and soft limits on number of files is set so that cdsw is happy
# Set the limits permanently:
cat > /etc/security/limits.conf <<EOF
* soft nofile 1048576
* hard nofile 1048576
EOF

# Director waits until it can ssh before continuing
service sshd stop
shutdown -f -r 1

echo "Finished cdsw pre"
