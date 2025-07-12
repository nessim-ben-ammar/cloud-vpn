# Cloud VPN with AWS Global Accelerator

This repository contains Terraform configurations and helper scripts to deploy a WireGuard VPN on AWS. The setup uses **AWS Global Accelerator** to expose a stable DNS name that clients can use instead of the instance's public IP.

## Usage

1. Deploy the infrastructure from the `iac/` folder using Terraform.
2. Use `clients/add_client.sh <name>` to create a new WireGuard client configuration.
   The script fetches the Global Accelerator DNS so the generated config will keep
   working even if the instance IP changes.
3. Optionally run `clients/backup_keys.sh <s3-bucket>` to archive server keys and
   client configurations to an S3 bucket. Use `clients/restore_keys.sh <s3-bucket>`
   on a fresh instance to restore the configuration and keep existing clients.

## Restoring Configuration

To spin up a new instance in another region:

1. Deploy the Terraform configuration again (potentially with a different region).
2. Run `clients/restore_keys.sh <s3-bucket>` to download the archived
   configuration from S3 and apply it to the new instance.

Because the clients use the Global Accelerator DNS, no changes are required on
client devices.
