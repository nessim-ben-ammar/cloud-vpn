resource "aws_vpc" "cloud_vpn_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "cloud_vpn_ig" {
  vpc_id = aws_vpc.cloud_vpn_vpc.id
}

resource "aws_subnet" "cloud_vpn_pub_sn" {
  vpc_id                  = aws_vpc.cloud_vpn_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
}

resource "aws_route_table" "cloud_vpn_pub_rt" {
  vpc_id = aws_vpc.cloud_vpn_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloud_vpn_ig.id
  }
}

resource "aws_route_table_association" "cloud_vpn_pub_rt_assoc" {
  subnet_id      = aws_subnet.cloud_vpn_pub_sn.id
  route_table_id = aws_route_table.cloud_vpn_pub_rt.id
}

resource "aws_security_group" "cloud_vpn_sg" {
  name   = "cloud-vpn-sg"
  vpc_id = aws_vpc.cloud_vpn_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "WireGuard"
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "GA Health Check TCP 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Configure AWS Global Accelerator to speed up VPN access

resource "aws_globalaccelerator_accelerator" "cloud_vpn" {
  name    = "cloud-vpn-accelerator"
  enabled = true
}

resource "aws_globalaccelerator_listener" "cloud_vpn" {
  accelerator_arn = aws_globalaccelerator_accelerator.cloud_vpn.id
  client_affinity = "NONE"
  protocol        = "UDP"

  port_range {
    from_port = 51820
    to_port   = 51820
  }
}

resource "aws_globalaccelerator_endpoint_group" "cloud_vpn" {
  listener_arn          = aws_globalaccelerator_listener.cloud_vpn.id
  endpoint_group_region = var.region
  health_check_protocol = "TCP"
  health_check_port     = 8080

  endpoint_configuration {
    endpoint_id                    = aws_instance.cloud_vpn_instance.id
    weight                         = 128
    client_ip_preservation_enabled = true
  }
}
