#! /bin/bash
# Author : Mangeshkumar B Bharsakle

apt-get install ntp -y
#Install the rdo-release-kilo package to enable the RDO repository:

apt-get install ubuntu-cloud-keyring
echo "deb http://ubuntu-cloud.archive.canonical.com/ubuntu" \
  "trusty-updates/kilo main" > /etc/apt/sources.list.d/cloudarchive-kilo.list

apt-get update



service ntp restart
#Install Compute-Node Packages

apt-get install nova-compute sysfsutils -y

. /root/requirment.sh

service_pass=$openstack


echo "
[DEFAULT]

logdir=/var/log/nova
state_path=/var/lib/nova
lock_path=/var/lock/nova



rpc_backend = rabbit
auth_strategy = keystone 
my_ip = $Comp_IP


#keys_path=$state_path/keys
#state_path=/var/lib/nova
#lock_path=/var/lib/nova/tmp
#log_dir=/var/log/nova

verbose = True

vnc_enabled = True
vncserver_listen = 0.0.0.0
vncserver_proxyclient_address = $Comp_IP
novncproxy_base_url = http://$Con_IP:6080/vnc_auto.html

# Network Configuration

network_api_class = nova.network.neutronv2.api.API
security_group_api = neutron
linuxnet_interface_driver = nova.network.linux_net.LinuxOVSInterfaceDriver
firewall_driver = nova.virt.firewall.NoopFirewallDriver


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

[neutron]
url = http://controller:9696
auth_strategy = keystone
admin_auth_url = http://controller:35357/v2.0
admin_tenant_name = service
admin_username = neutron
admin_password = $service_pass

" > /etc/nova/nova.conf

#if compute node is virtual - change virt_type to qemu
var=`egrep -c '(vmx|svm)' /proc/cpuinfo`


if [  $var -eq 0 ]; then
 sed -i "s/virt_type=kvm/virt_type=qemu/g" /etc/nova/nova-compute.conf  
fi

service nova-compute restart

rm -f /var/lib/nova/nova.sqlite
