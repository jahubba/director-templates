# Director templates
Modular director templates, makes use of HOCON include.  This uses current features and Director 2.4 is required.  You can use the cloud configuraiton files how you would normally run them with director cli
```
cloudera-director bootstrap-remote aws.conf --lp.remote.username=admin --lp.remote.password=admin
```

A decision decision was to utilize the director client cli and not create a new cli.  Because of some limitations with HOCON, it isn't possible to dynamically load properties, so files will need to be modified to add or remove services.  The general.conf file provides services, the default is to install core hadoop services and cdsw, but you can uncomment any of the other services to have director install and configure them.

The cloudera manager admin password is changed to 'cloudera'.  Files to be used with the director client cli are aws.conf, gcp.conf or azure.conf.

# Versions
Component | Version
----- | -----
CDH | 5.12
CDSW | 1.1
KUDU | 1.4
Spark | 2.2

# Use
Create a provider-keys.conf file within a secrets directory in the parent of this directory.  There is a limitation that does not allow substition within include statement, but this file should not be committed to version control, change this path as desired either relative or absolute.  This will be parsed as HOCON, but HOCON does not enforce curly braces, so this can be treated as a normal property files.  Add your cloud credentials or other secrets here.
```
AWS_ACCESS_KEY_ID="MYACCESSKEY"
AWS_SECRET_ACCESS_KEY="MYSECRETKEY"

AZURE_CLIENT_SECRET="AZURESECRET"

GCP_JSON_KEY="""{
  GCPJSON
}"""
```

## CDSW
This currently sets up a CDH cluster and installs CDSW on an edge node.  Spark2 is automatically installed along with the Anaconda parcel.  The anaconda python executable is set as default for spark.  The default also creates a DNS on the CDSW node and creates a wildcard entry of *.cdsw.cloudera.internal  You will then need to use port forwarding into the CDSW to access the CDSW UI and connect to the UI with http://cdsw.cloudera.internal.  If desired, you can use xip.io instead of DNS by switching the commented lines at the bottom of the cdsw.conf file.

## AWS
The AWS template also includes an S3 configuration that uses the AWS credentials used to provision the EC2 instances to allow S3 access via HDFS client.  It creates an external account within Cloudera Manager and sets up the AWS_S3 service for the cluster.  It also enables server side encryption for S3 and increases the block size.

## Azure
An external DNS is still required and will need to be setup prior to executing.  Additional work can be completed to check for DNS before using a seperate one for CDSW.  Also, azure has some NTP sync issues and a script is included to disable host time sync.  Not always required, but KUDU is especially sensitive to these issues.

## GCP
The CentOS 7 image is not available by default and will need ot be added to the google plugin.  Add the line below to the google.conf file in the correct version plugin file (currently /var/lib/cloudera-director-plugins/google-provider-1.0.4/etc/google.conf)
```
centos7 = "https://www.googleapis.com/compute/v1/projects/centos-cloud/global/images/centos-7-v20170227"
```

## Scale
It's a little known secret, but Director has the ability to scale nodes at certain times.  This is a seperate cli call in a seperate process which runs continuously.  The scale.conf can be used to scale the worker nodes at specific times.  Update the names to point to the cluster you want to scale.
```
cloudera-director evaluate-policies-remote scale.conf --lp.remote.username=admin --lp.remote.password=admin
```