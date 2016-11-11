#! /bin/bash

# Author : Mangeshkumar B Bharsakle

#Install Basic Packages

apt-get install ntp -y

apt-get install ubuntu-cloud-keyring

echo "deb http://ubuntu-cloud.archive.canonical.com/ubuntu" \
  "trusty-updates/kilo main" > /etc/apt/sources.list.d/cloudarchive-kilo.list

apt-get update




. /root/requirment.sh

service_pass=$openstack
echo "

net.ipv4.ip_forward=1
net.ipv4.conf.all.rp_filter=0
net.ipv4.conf.default.rp_filter=0

" > /etc/sysctl.conf

#Implement the changes:

sysctl -p

#To install the Networking components

apt-get install neutron-plugin-ml2 neutron-plugin-openvswitch-agent \
  neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent -y
#To configure the Networking common components

echo "
[DEFAULT]
rpc_backend = rabbit
auth_strategy = keystone
core_plugin = ml2
service_plugins = router
allow_overlapping_ips = True

verbose = True
 
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
username = neutron
password = $service_pass

[agent]
root_helper = sudo /usr/bin/neutron-rootwrap /etc/neutron/rootwrap.conf
[oslo_concurrency]
lock_path = \$state_path/lock

" > /etc/neutron/neutron.conf


echo "

[ml2]
type_drivers = flat,vlan,gre,vxlan
tenant_network_types = gre
mechanism_drivers = openvswitch

[ml2_type_flat]
flat_networks = external

[ml2_type_gre]
tunnel_id_ranges = 1:1000

[securitygroup]
enable_security_group = True
enable_ipset = True
firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver

[ovs]
local_ip = $NET_IP
bridge_mappings = external:br-ex

[agent]
tunnel_types = gre

" > /etc/neutron/plugins/ml2/ml2_conf.ini


echo "
[DEFAULT]
interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver
external_network_bridge =
router_delete_namespaces = True

verbose = True

" > /etc/neutron/l3_agent.ini

echo "
[DEFAULT]
interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver
dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq
dhcp_delete_namespaces = True
verbose = True
dnsmasq_config_file = /etc/neutron/dnsmasq-neutron.conf

" > /etc/neutron/dhcp_agent.ini

echo "
dhcp-option-force=26,1454
" > /etc/neutron/dnsmasq-neutron.conf

echo "
[DEFAULT]
auth_uri = http://controller:5000
auth_url = http://controller:35357
auth_region = RegionOne
auth_plugin = password
project_domain_id = default
user_domain_id = default
project_name = service
username = neutron
password = $service_pass

nova_metadata_ip = controller

metadata_proxy_shared_secret = $service_pass

verbose = True

" > /etc/neutron/metadata_agent.ini

#To configure the Open vSwitch (OVS) service

#Start the OVS service and configure it to start when the system boots:

service openvswitch-switch restart

#Add the external bridge:

ovs-vsctl add-br br-ex

#Add a port to the external bridge that connects to the physical external network interface:

ovs-vsctl add-port br-ex $INTERFACE_NAME

ethtool -K $INTERFACE_NAME gro off

#To finalize the installation


#Start the Networking services and configure them to start when the system boots:

service  neutron-plugin-openvswitch-agent restart
 service neutron-l3-agent restart
 service neutron-dhcp-agent restart
 service neutron-metadata-agent restart

