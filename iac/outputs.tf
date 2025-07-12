output "instance_public_ip" {
  description = "Public IP address of the cloud VPN instance"
  value       = aws_instance.cloud_vpn_instance.public_ip
}

# Output SSH connection command
output "ssh_connection_command" {
  description = "Command to connect to the instance via SSH"
  value       = "ssh -i ${local_file.ssh_private_key.filename} ubuntu@${aws_instance.cloud_vpn_instance.public_ip}"
}

# Expose the Global Accelerator DNS name
output "global_accelerator_dns" {
  description = "DNS name for the Global Accelerator"
  value       = aws_globalaccelerator_accelerator.cloud_vpn.dns_name
}


