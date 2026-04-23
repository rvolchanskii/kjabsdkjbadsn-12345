variable "distributions_config" {
  description = "CloudFront dictributions configuration from YAML file"
  type        = any
}

variable "domains_config" {
  description = "Domains configuration from YAML file"
  type        = any
}

variable "certificate_arns" {
  description = "ACM certificates"
  type        = map(string)
}
