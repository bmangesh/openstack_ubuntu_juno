#! /bin/bash

# Author : Mangeshkumar B Bharsakle
# load service pass from config env
. /root/requirment.sh

service_pass=$openstack
# we create a quantum db irregardless of whether the user wants to install quantum
mysql -u root -p$service_pass <<EOF
CREATE DATABASE glance;
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY '$service_pass';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'controller' IDENTIFIED BY '$service_pass';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY '$service_pass';
EOF

. /root/admin-openrc.sh

. /root/requirment.sh

service_pass=$openstack

#Create the glance user:
keystone user-create --name glance --pass $service_pass


#Add the admin role to the glance user and service project:
keystone user-role-add --user glance --tenant service --role admin


#Create the glance service entity:

keystone service-create --name glance --type image --description "OpenStack Image Service"


#Create the Image service API endpoint:

keystone endpoint-create \
  --service-id $(keystone service-list | awk '/ image / {print $2}') \
  --publicurl http://controller:9292 \
  --internalurl http://controller:9292 \
  --adminurl http://controller:9292 \
  --region regionOne

#Install the Glance  packages:

apt-get install glance python-glanceclient -y



echo "
[DEFAULT]
notification_driver = noop
verbose = True

[database]
connection = mysql://glance:$service_pass@controller/glance

[keystone_authtoken]
auth_uri = http://controller:5000/v2.0
auth_url = http://controller:35357
admin_tenant_name = service
admin_user = glance
admin_password = $service_pass
 
[paste_deploy]
flavor = keystone

[glance_store]
default_store = file
filesystem_store_datadir = /var/lib/glance/images/
" > /etc/glance/glance-api.conf


echo "
[DEFAULT]
notification_driver = noop
verbose = True

[database]
connection = mysql://glance:$service_pass@controller/glance

[keystone_authtoken]
auth_uri = http://controller:5000/v2.0
identity_uri = http://controller:35357
admin_tenant_name = service
admin_user = glance
admin_password = $service_pass

[paste_deploy]
flavor = keystone


" > /etc/glance/glance-registry.conf

#Populate the Image service database:
su -s /bin/sh -c "glance-manage db_sync" glance

service glance-registry restart



service glance-api restart

rm -f /var/lib/glance/glance.sqlite


######echo "export OS_IMAGE_API_VERSION=2" | tee -a /root/admin-openrc.sh 

mkdir /tmp/images
wget -P /tmp/images http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img

glance image-list
. /root/admin-openrc.sh

glance image-create --name "cirros-0.3.3-x86_64" --file /tmp/images/cirros-0.3.3-x86_64-disk.img \
  --disk-format qcow2 --container-format bare --is-public True --progress

glance image-list
