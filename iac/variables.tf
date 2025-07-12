variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "deploy_global_accelerator" {
  description = "Deploy AWS Global Accelerator to expose a stable DNS"
  type        = bool
  default     = false
}

variable "assign_elastic_ip" {
  description = "Attach an Elastic IP to the instance for a persistent public IP"
  type        = bool
  default     = false
}

locals {
  availability_zone = "${var.region}a"
}
