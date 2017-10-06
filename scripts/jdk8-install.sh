#!/bin/bash

export JDK_URL=http://download.oracle.com/otn-pub/java/jdk/8u141-b15/336fa29ff2bb4ef291e347e091f7f4a7/jdk-8u141-linux-x64.rpm
yum -y install wget
wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" $JDK_URL -O /tmp/jdk.rpm
rpm -ivh /tmp/jdk.rpm
rm -f /tmp/jdk.rpm