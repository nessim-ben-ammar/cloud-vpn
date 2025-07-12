# Cloud VPN with AWS Global Accelerator

This repository contains Terraform configurations and helper scripts to deploy a WireGuard VPN on AWS. By default it creates a regular EC2 instance reachable via its public IP. Set `deploy_global_accelerator=true` to provision **AWS Global Accelerator**, or `assign_elastic_ip=true` to attach a persistent static IP.

## Usage

1. Deploy the infrastructure from the `iac/` folder using Terraform. Enable features with:
   - `-var deploy_global_accelerator=true` to add Global Accelerator.
   - `-var assign_elastic_ip=true` for a fixed IP when not using Global Accelerator.
2. Use `clients/add_client.sh <name>` to create a new WireGuard client configuration.
   The script automatically fetches the current VPN endpoint (either the Accelerator DNS, the static IP, or the instance IP), so the generated config keeps working after redeploys.
3. Use `clients/backup_configs.sh` to download a compressed archive of all client
   configuration files via `scp`. The archive is saved as `wireguard-backup.tar.gz`
   in the `clients/` directory.
4. Run `clients/restore_configs.sh [archive]` to upload a previously downloaded
   archive to a new instance and restart WireGuard.

## Restoring Configuration

To migrate the VPN to another region:

1. Deploy the Terraform configuration again in the new region.

If you keep Global Accelerator deployed, its DNS name remains unchanged globally so existing client configs continue to work.
When relying on a static IP, the address only persists within a region. Moving regions means a new Elastic IP will be allocated and clients must update their configuration.
Using `assign_elastic_ip=true` avoids any changes while you remain in the same region.
