#!/bin/bash

# Destroy all regional resources while preserving Global Accelerator
# This allows for seamless region migration

echo "Destroying regional resources (keeping Global Accelerator)..."

terraform destroy \
  -target=aws_instance.cloud_vpn_instance \
  -target=aws_vpc.cloud_vpn_vpc \
  -target=aws_subnet.cloud_vpn_pub_sn \
  -target=aws_internet_gateway.cloud_vpn_ig \
  -target=aws_route_table.cloud_vpn_pub_rt \
  -target=aws_route_table_association.cloud_vpn_pub_rt_assoc \
  -target=aws_security_group.cloud_vpn_sg \
  -target=aws_key_pair.cloud_vpn_ssh_key \
  -target=aws_globalaccelerator_endpoint_group.cloud_vpn \
  -target=local_file.ssh_private_key \
  -target=local_file.ssh_public_key \
  -target=tls_private_key.ssh_key

echo "Regional resources destroyed. Global Accelerator preserved."
echo "You can now change regions and run 'terraform apply' to deploy elsewhere."
