#! /bin/bash

# Author : Mangeshkumar B Bharsakle

# load service pass from config env
. /root/requirment.sh

service_pass=$openstack
# we create a quantum db irregardless of whether the user wants to install quantum
mysql -u root -p$service_pass <<EOF
CREATE DATABASE nova;
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '$service_pass';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'controller' IDENTIFIED BY '$service_pass';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '$service_pass';
EOF

#Source the admin credentials to gain access to admin-only CLI commands:

. /root/admin-openrc.sh

#Create the nova user:
. /root/requirment.sh

service_pass=$openstack

openstack user create nova --password $service_pass

#Add the admin role to the nova user:

openstack role add --project service --user nova admin

#Create the nova service entity:

openstack service create --name nova \
  --description "OpenStack Compute" compute

#Create the Compute service API endpoint:

openstack endpoint create \
  --publicurl http://controller:8774/v2/%\(tenant_id\)s \
  --internalurl http://controller:8774/v2/%\(tenant_id\)s \
  --adminurl http://controller:8774/v2/%\(tenant_id\)s \
  --region RegionOne \
  compute

##To install and configure Compute controller components

#Install the packages:

apt-get install nova-api nova-cert nova-conductor nova-consoleauth \
  nova-novncproxy nova-scheduler python-novaclient -y

echo "

[DEFAULT]
rpc_backend = rabbit
auth_strategy = keystone
verbose = True
my_ip = $Con_IP

keys_path=\$state_path/keys
state_path=/var/lib/nova
lock_path=/var/lib/nova/tmp
log_dir=/var/log/nova


vncserver_listen = $Con_IP
vncserver_proxyclient_address = $Con_IP

[database]
connection = mysql://nova:$service_pass@controller/nova
 
[oslo_messaging_rabbit]
rabbit_host = controller
rabbit_userid = openstack
rabbit_password = $service_pass

 
[keystone_authtoken]
auth_uri = http://controller:5000
auth_url = http://controller:35357
auth_plugin = password
project_domain_id = default
user_domain_id = default
project_name = service
username = nova
password = $service_pass

[glance]
host = controller

[oslo_concurrency]
lock_path = /var/lib/nova/tmp

" > /etc/nova/nova.conf

su -s /bin/sh -c "nova-manage db sync" nova

#finalize installation Steps

#Start the Compute services and configure them to start when the system boots:

#Restart the Compute services:

 service nova-api restart
 service nova-cert restart
 service nova-consoleauth restart
 service nova-scheduler restart
 service nova-conductor restart
 service nova-novncproxy restart


rm -f /var/lib/nova/nova.sqlite
