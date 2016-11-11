#! /bin/bash
# Author : Mangeshkumar B Bharsakle

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "You need to be 'root' " 1>&2
   exit 1
fi


echo "######################################################################################################"

echo;
echo "Before, Installing This Script Nedd Some Input From User "

echo;
echo "Please Enter Following Details"

echo;
echo "#######################################################################################################"

read -p "Enter the IP Address of Controller Node " controller

read -p "Enter the IP Address of Compute Node    " compute

read -p "Enter the IP Address of Network Node    " network

read -p "Enter Neutron INTERFACE_NAME To Use    " INTERFACE

echo  " ***Please Don't Use @ in Password***  "
read -p " Enter Password For OpenStack Services  " password

cat > /root/requirment.sh <<EOF
# set up env variables for install
export Con_IP=$controller
export Comp_IP=$compute
export NET_IP=$network
export INTERFACE_NAME=$INTERFACE
export openstack=$password
EOF

cat > /etc/hosts <<EOF
#Openstack FDDN
$controller controller
$compute  compute
$network network
EOF

echo "Please press Enter to Generate SSH Key"
ssh-keygen

echo "Please Copy ssh-key ID in Compute Node"

ssh-copy-id compute

echo "Please Copy ssh-key ID in Network Node"

ssh-copy-id network

