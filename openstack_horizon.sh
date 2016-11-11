#! /bin/bash
# Author : Mangeshkumar B Bharsakle

#Install Horizon Package

apt-get install openstack-dashboard -y

sed -i "s/OPENSTACK_HOST = \"127.0.0.1\"/OPENSTACK_HOST = \"controller\"/g" /etc/openstack-dashboard/local_settings.py

sed -i "s/OPENSTACK_KEYSTONE_DEFAULT_ROLE = \"_member_\"/OPENSTACK_KEYSTONE_DEFAULT_ROLE = \"user\"/g" /etc/openstack-dashboard/local_settings.py

#Reload the web server configuration:

service apache2 reload
