#!/bin/bash

if rpm -q cloudera-data-science-workbench 
then
  set -x
  exec > ~/bootstrap-cdsw-post.log 2>&1

  # renable ip6 and iptables after director disabled
  sed -i "/net.ipv6.conf.all.disable_ipv6/d" /etc/sysctl.conf
  sed -i "/net.ipv6.conf.default.disable_ipv6/d" /etc/sysctl.conf
  echo "net.ipv6.conf.all.disable_ipv6=0" >> /etc/sysctl.conf
  echo "net.ipv6.conf.default.disable_ipv6=0" >> /etc/sysctl.conf
  echo "net.bridge.bridge-nf-call-iptables=1" >> /etc/sysctl.conf
  sysctl -p

  systemctl enable rpcbind
  systemctl restart rpcbind
  systemctl restart rpc-statd

  block_devices=($(awk '/\/data/ {print $1}' /etc/fstab))
  mount_points=($(awk '/\data/ {print $2}' /etc/fstab))
  sed -i "/DOCKER_BLOCK_DEVICES=/cDOCKER_BLOCK_DEVICES=\"${block_devices[0]}\"" /etc/cdsw/config/cdsw.conf
  sed -i "/APPLICATION_BLOCK_DEVICE=/cAPPLICATION_BLOCK_DEVICE=\"${block_devices[1]}\"" /etc/cdsw/config/cdsw.conf
  sed -i "\~${block_devices[0]}~ d" /etc/fstab
  sed -i "\~${block_devices[1]}~ d" /etc/fstab
  umount "${mount_points[0]}"
  umount "${mount_points[1]}"

  # Director black lists iptables, need to re-enable for cdsw
  rm -f /etc/modprobe.d/iptables-blacklist.conf
  modprobe ip_tables
  modprobe iptable_filter

  ip=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
  sed -i "/nameserver/c nameserver ${ip}" /etc/resolv.conf

  # Initialize cdsw, use echo to hit enter for ulimit warning
  cdsw init
fi
echo "Finished cdsw post"
