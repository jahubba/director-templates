#!/bin/bash

set -x
exec > ~/bootstrap-cdsw-dns.log 2>&1

yum -y install bind bind-utils

fqdn=$(hostname -f)
domain=cloudera.internal
host=$(hostname -s)
ip=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
dnsserver=$(cat /etc/resolv.conf | grep -i nameserver | head -n1 | cut -d ' ' -f2)

sed -i "/DOMAIN=/cDOMAIN=\"cdsw.cloudera.internal\"" /etc/cdsw/config/cdsw.conf

echo "include \"/etc/named/named.conf.local\";" >> /etc/named.conf
sed "/options {/a \\\tforwarders { ${dnsserver}; };" -i /etc/named.conf
sed "/listen-on port 53/c \\\tlisten-on port 53 { any; };" -i /etc/named.conf
sed "/allow-query /c \\\tallow-query     { any; };" -i /etc/named.conf
sed "/dnssec-validation/c \\\tdnssec-validation no;" -i /etc/named.conf

cat >/etc/named/named.conf.local <<EOF
zone "${domain}" IN {
  type master;
  file "/etc/named/internal.zone";
};
EOF

cat >/etc/named/internal.zone <<EOF
\$ORIGIN ${domain}.
\$TTL 600  ; 10 minutes
@  IN SOA  ${fqdn}. root.${fqdn}. (
        10        ; serial
        600        ; refresh (10 minutes)
        60        ; retry (1 minute)
        604800    ; expire (1 week)
        600        ; minimum (10 minutes)
        )
        NS  ${fqdn}.
${host} IN      A       ${ip}
cdsw    IN      CNAME   ${host}
*.cdsw  IN      CNAME   ${host}
EOF

systemctl enable named
systemctl restart named

echo "Finished cdsw dns"
