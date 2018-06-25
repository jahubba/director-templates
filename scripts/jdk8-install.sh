#!/bin/bash

yum remove -y *openjdk*
rpm -ivh "https://archive.cloudera.com/director/redhat/7/x86_64/director/2.6.0/RPMS/x86_64/oracle-j2sdk1.8-1.8.0+update121-1.x86_64.rpm"
