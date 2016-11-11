#! /bin/bash
# Author : Mangeshkumar B Bharsakle

# load service pass from config env
. /root/requirment.sh

service_pass=$openstack

#Create keystone DB in mysql

mysql -u root -p$service_pass <<EOF
CREATE DATABASE keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY '$service_pass';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'controller' IDENTIFIED BY '$service_pass';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY '$service_pass';
EOF

#Generate Random Token

token=`cat /dev/urandom | head -c2048 | md5sum | cut -d' ' -f1`

#Stop Keyston to Auto Start


#Install Keystone Packages

apt-get install keystone python-keystoneclient

#Edit Keystone Configuration File
echo "
[DEFAULT]
admin_token =$token
verbose = True
[database]
connection = mysql://keystone:$service_pass@controller/keystone

[token]
provider = keystone.token.providers.uuid.Provider
driver = keystone.token.persistence.backends.sql.Token

[revoke]
driver = keystone.contrib.revoke.backends.sql.Revoke

" > /etc/keystone/keystone.conf

#Populate Keystone DB in Mysql

su -s /bin/sh -c "keystone-manage db_sync" keystone


service keystone restart

rm -f /var/lib/keystone/keystone.db


(crontab -l -u keystone 2>&1 | grep -q token_flush) || \
  echo '@hourly /usr/bin/keystone-manage token_flush >/var/log/keystone/keystone-tokenflush.log 2>&1' \
  >> /var/spool/cron/crontabs/keystone



#Create admin-openrc.sh

cat > /root/admin-openrc.sh <<EOF
# set up env variables for install
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$service_pass
export OS_AUTH_URL=http://controller:35357/v2.0
EOF

