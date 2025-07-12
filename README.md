# Cloud VPN with AWS Global Accelerator

This repository contains Terraform configurations and helper scripts to deploy a WireGuard VPN on AWS. The setup uses **AWS Global Accelerator** to expose a stable DNS name that clients can use instead of the instance's public IP.

## Usage

1. Deploy the infrastructure from the `iac/` folder using Terraform. The server
   boots from the latest Ubuntu image.
2. Use `clients/add_client.sh <name>` to create a new WireGuard client configuration.
   The script fetches the Global Accelerator DNS so the generated config will keep
   working even if the instance IP changes.
3. Client configurations are backed up locally. The `add_client.sh` script
   automatically invokes `backup_configs.sh` so your current keys are saved
   under the `backups/` directory.
4. Use `clients/export_configs.sh` if you need to download all client
   configuration files for reference.

## Restoring Configuration

To spin up a new instance in another region:

1. Deploy the Terraform configuration (optionally changing the region).
2. Run `clients/restore_configs.sh <backup-file>` to copy a previously created
   backup onto the new instance and restart WireGuard.

Because the clients use the Global Accelerator DNS, no changes are required on
client devices.
