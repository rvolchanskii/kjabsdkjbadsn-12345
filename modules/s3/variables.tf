variable "cdn_bucket_name" {
  description = "Name of the main CDN S3 bucket"
  type        = string
  default     = "aws-taxi-cdn-cloudfront"
}

variable "cdn_bucket_ownership" {
  description = "Object ownership setting for the CDN bucket"
  type        = string
  default     = "ObjectWriter"
}

variable "cdn_bucket_block_public_acls" {
  description = "Whether to block public ACLs for the CDN bucket"
  type        = bool
  default     = true
}

variable "cdn_bucket_block_public_policy" {
  description = "Whether to block public bucket policies for the CDN bucket"
  type        = bool
  default     = true
}

variable "cdn_bucket_ignore_public_acls" {
  description = "Whether to ignore public ACLs for the CDN bucket"
  type        = bool
  default     = true
}

variable "cdn_bucket_restrict_public_buckets" {
  description = "Whether to restrict public bucket policies for the CDN bucket"
  type        = bool
  default     = true
}

variable "default_tags" {
  description = "Default tags to apply to all resources"
  type        = map(string)
  default     = {}
}
