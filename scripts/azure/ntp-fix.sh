#!/bin/bash

set -x
exec > ~/bootstrap-azure-ntp.log 2>&1

# Fix Azure clock issues (required for KUDU)
yum install -y ntp ntpdate ntp-doc
service ntpd stop
grep -l 9527e630-d0ae-497b-adce-e80ab0175caf /sys/bus/vmbus/devices/*/class_id | xargs dirname | xargs basename > /sys/bus/vmbus/drivers/hv_util/unbind
ntptime -s 0 
service ntpd start
chkconfig ntpd on
ntpd -q
echo "grep -l 9527e630-d0ae-497b-adce-e80ab0175caf /sys/bus/vmbus/devices/*/class_id | xargs dirname | xargs basename > /sys/bus/vmbus/drivers/hv_util/unbind" >> /etc/rc.local

echo "Finished azure ntp fix"
