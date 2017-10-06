#!/bin/bash

set -x
exec > ~/bootstrap-cdsw-xipio.log 2>&1

ip=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
sed -i "/DOMAIN=/cDOMAIN=\"${private_ip}.xip.io\"" /etc/cdsw/config/cdsw.conf

echo "Finished cdsw xipio"
