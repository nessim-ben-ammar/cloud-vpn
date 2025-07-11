# Output the public IP
output "instance_public_ip" {
  description = "Public IP address of the cloud VPN instance"
  value       = oci_core_instance.cloud_vpn_instance.public_ip
}

# Output SSH connection command
output "ssh_connection_command" {
  description = "Command to connect to the instance via SSH"
  value       = "ssh -i ${local_file.ssh_private_key.filename} ubuntu@${oci_core_instance.cloud_vpn_instance.public_ip}"
}
