output "cdn_bucket_id" {
  description = "ID of the CDN S3 bucket"
  value       = aws_s3_bucket.cdn_bucket.id
}

output "cdn_bucket_arn" {
  description = "ARN of the CDN S3 bucket"
  value       = aws_s3_bucket.cdn_bucket.arn
}

output "cdn_bucket_domain_name" {
  description = "Domain name of the CDN S3 bucket"
  value       = aws_s3_bucket.cdn_bucket.bucket_domain_name
}

output "cdn_bucket_regional_domain_name" {
  description = "Regional domain name of the CDN S3 bucket"
  value       = aws_s3_bucket.cdn_bucket.bucket_regional_domain_name
}
