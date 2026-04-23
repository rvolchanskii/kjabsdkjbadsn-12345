variable "records" {
  description = "Map of DNS records to create"
  type = map(object({
    fqdn = string
    type = string
    ttl  = number
    data = string
  }))
  default = {}
}

variable "description" {
  description = "Description of the DNS records being created"
  type        = string
  default     = "Managed by Terraform DNS module"
}