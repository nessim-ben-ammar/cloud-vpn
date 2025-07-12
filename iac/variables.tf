variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

locals {
  availability_zone = "${var.region}a"
}
