variable "tenancy_ocid" {
  description = "The OCID of the tenancy"
  type        = string
  default     = "ocid1.tenancy.oc1..aaaaaaaaerpfsav3vgybi7nylv2qojstwz6l4s275fxvczvwzspzvvrmt3rq"
}

variable "region" {
  description = "The OCI region to deploy resources in"
  type        = string
  default     = "eu-frankfurt-1"
}
