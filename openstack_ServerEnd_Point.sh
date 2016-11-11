#! /bin/bash
# Author : Mangeshkumar B Bharsakle

.  /root/admin-openrc.sh

keystone service-create --name keystone --type identity --description "OpenStack Identity"

keystone endpoint-create \
  --service-id $(keystone service-list | awk '/ identity / {print $2}') \
  --publicurl http://controller:5000/v2.0 \
  --internalurl http://controller:5000/v2.0 \
  --adminurl http://controller:35357/v2.0 \
  --region regionOne



#To create tenants, users, and roles

#Create the admin project:

. /root/requirment.sh

service_pass=$openstack


keystone tenant-create --name admin --description "Admin Tenant"

keystone user-create --name admin --pass $service_pass --email mangesh.bharsakle@afourtech.com
#Create the admin user:


#Create the admin role:

keystone role-create --name admin

#Add the admin role to the admin project and user:

keystone user-role-add --user admin --tenant admin --role admin


keystone tenant-create --name service --description "Service Tenant"

#Create the service project:






