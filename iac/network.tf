resource "oci_identity_compartment" "cloud_vpn_cmp" {
  compartment_id = var.tenancy_ocid
  description    = "Compartment for cloud VPN resources in ${var.region}"
  name           = "cloud-vpn-${var.region}-compartment"
  enable_delete  = true
}

resource "oci_core_vcn" "cloud_vpn_vcn" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = oci_identity_compartment.cloud_vpn_cmp.id
  display_name   = "cloud-vpn-${var.region}-vcn"
}

resource "oci_core_internet_gateway" "cloud_vpn_ig" {
  compartment_id = oci_identity_compartment.cloud_vpn_cmp.id
  vcn_id         = oci_core_vcn.cloud_vpn_vcn.id
  display_name   = "cloud-vpn-${var.region}-ig"
}

resource "oci_core_subnet" "cloud_vpn_pub_sn" {
  compartment_id    = oci_identity_compartment.cloud_vpn_cmp.id
  vcn_id            = oci_core_vcn.cloud_vpn_vcn.id
  cidr_block        = "10.0.0.0/24"
  display_name      = "cloud-vpn-${var.region}-pub-sn"
  route_table_id    = oci_core_route_table.cloud_vpn_pub_rt.id
  security_list_ids = [oci_core_security_list.cloud_vpn_pub_sl.id]
}
resource "oci_core_route_table" "cloud_vpn_pub_rt" {
  compartment_id = oci_identity_compartment.cloud_vpn_cmp.id
  vcn_id         = oci_core_vcn.cloud_vpn_vcn.id
  display_name   = "cloud-vpn-${var.region}-pub-rt"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.cloud_vpn_ig.id
  }
}

resource "oci_core_security_list" "cloud_vpn_pub_sl" {
  compartment_id = oci_identity_compartment.cloud_vpn_cmp.id
  vcn_id         = oci_core_vcn.cloud_vpn_vcn.id
  display_name   = "cloud-vpn-${var.region}-pub-sl"

  # Allow all outbound traffic (required for VPN to access internet)
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  # SSH access
  ingress_security_rules {
    protocol = "6" # TCP
    source   = "0.0.0.0/0"
    tcp_options {
      max = 22
      min = 22
    }
  }

  # WireGuard VPN (default port 51820 UDP)
  ingress_security_rules {
    protocol = "17" # UDP
    source   = "0.0.0.0/0"
    udp_options {
      max = 51820
      min = 51820
    }
  }

  # ICMP for path MTU discovery and ping
  ingress_security_rules {
    protocol = "1" # ICMP
    source   = "0.0.0.0/0"
    icmp_options {
      type = 3
      code = 4
    }
  }

  # ICMP for ping (optional, for troubleshooting)
  ingress_security_rules {
    protocol = "1" # ICMP
    source   = "0.0.0.0/0"
    icmp_options {
      type = 8
      code = 0
    }
  }
}
