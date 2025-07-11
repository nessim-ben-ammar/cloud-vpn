# Data source to get the latest Ubuntu 24.04 Minimal image for AMD64
data "oci_core_images" "ubuntu_images" {
  compartment_id           = oci_identity_compartment.cloud_vpn_cmp.id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04 Minimal"
  shape                    = "VM.Standard.E3.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# Data source to get availability domains
data "oci_identity_availability_domains" "ads" {
  compartment_id = oci_identity_compartment.cloud_vpn_cmp.id
}

# Generate SSH key pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the private key locally
resource "local_file" "ssh_private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/ssh_keys/oci-instance-ssh-key"
  file_permission = "0600"
}

# Save the public key locally
resource "local_file" "ssh_public_key" {
  content  = tls_private_key.ssh_key.public_key_openssh
  filename = "${path.module}/ssh_keys/oci-instance-ssh-key.pub"
}

# Read existing SSH public key
locals {
  ssh_public_key = tls_private_key.ssh_key.public_key_openssh
}

# Create the compute instance
resource "oci_core_instance" "cloud_vpn_instance" {
  availability_domain = var.availability_domain
  compartment_id      = oci_identity_compartment.cloud_vpn_cmp.id
  display_name        = "cloud-vpn-${var.region}-instance"
  shape               = "VM.Standard.E3.Flex"

  shape_config {
    ocpus         = 1
    memory_in_gbs = 4
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.cloud_vpn_pub_sn.id
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu_images.images[0].id
  }

  metadata = {
    ssh_authorized_keys = local.ssh_public_key
    user_data           = base64encode(file("${path.module}/user-data.yaml"))
  }

  preserve_boot_volume = false
}
