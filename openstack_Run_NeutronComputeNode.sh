#! /bin/bash
# Author : Mangeshkumar B Bharsakle

. /root/requirment.sh
scp ./openstack_NeutronCompute.sh  $Comp_IP:/root/openstack_NeutronCompute.sh

ssh $Comp_IP "sh /root/openstack_NeutronCompute.sh"
