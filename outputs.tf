output "all_distribution_domains" {
  description = "All CloudFront distributions domains"
  value       = module.cloudfront.distribution_domains
}
