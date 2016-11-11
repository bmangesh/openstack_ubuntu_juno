#!/bin/bash
# Author : Mangeshkumar B Bharsakle

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "You need to be 'root' dude." 1>&2
   exit 1
fi

. /root/requirment.sh

service_pass=$openstack

# Install Basic Packages

apt-get install ntp -y

apt-get install ubuntu-cloud-keyring

echo "deb http://ubuntu-cloud.archive.canonical.com/ubuntu" \
  "trusty-updates/juno main" > /etc/apt/sources.list.d/cloudarchive-juno.list

 
apt-get update &&  apt-get dist-upgrade

export DEBIAN_FRONTEND=noninteractive

sudo -E apt-get -q -y install  mariadb-server python-mysqldb 

mysqladmin -u root password $openstack

#Configure Mysql openstack file
echo "
[mysqld]
bind-address = 0.0.0.0
default-storage-engine = innodb
innodb_file_per_table
collation-server = utf8_general_ci
init-connect = 'SET NAMES utf8'
character-set-server = utf8
" >> /etc/mysql/conf.d/mysqld_openstack.cnf

# restart Mysql Service
service mysql restart

# wait for restart
sleep 4 


#Install Rabbitmq-server 

apt-get install rabbitmq-server -y

sleep 60

#Add the openstack user to rabbitMQ

rabbitmqctl add_user guest  $openstack

#Permit configuration, write, and read access for the openstack user:

service rabbitmq-server restart

