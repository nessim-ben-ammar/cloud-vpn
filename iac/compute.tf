# Get the latest Ubuntu 24.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Generate SSH key pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the private key locally
resource "local_file" "ssh_private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/ssh_keys/aws-instance-ssh-key"
  file_permission = "0600"
}

# Save the public key locally
resource "local_file" "ssh_public_key" {
  content  = tls_private_key.ssh_key.public_key_openssh
  filename = "${path.module}/ssh_keys/aws-instance-ssh-key.pub"
}

resource "aws_key_pair" "cloud_vpn_ssh_key" {
  key_name   = "cloud-vpn-ssh-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "aws_instance" "cloud_vpn_instance" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.cloud_vpn_pub_sn.id
  vpc_security_group_ids      = [aws_security_group.cloud_vpn_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.cloud_vpn_ssh_key.key_name
  user_data                   = file("${path.module}/user-data.yaml")
}

