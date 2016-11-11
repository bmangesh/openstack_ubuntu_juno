#! /bin/bash
. /root/admin-openrc.sh

neutron net-create ext-net --shared --router:external True \
--provider:physical_network external --provider:network_type flat

neutron subnet-create ext-net --name ext-subnet \
--allocation-pool start=mangesh end=mangesh \
--disable-dhcp --gateway mangesh  mangesh/24

neutron net-create admin-net

neutron subnet-create admin-net --name admin-subnet \
--dns-nameserver 8.8.8.8 \
--gateway 10.10.10.1  10.10.10.0/24

neutron router-create admin-router

neutron router-interface-add admin-router admin-subnet

neutron router-gateway-set admin-router ext-net
