output "distribution_ids" {
  description = "CloudFront distributions IDs"
  value = {
    for key, dist in aws_cloudfront_distribution.distributions : key => dist.id
  }
}

output "distribution_domains" {
  description = "CloudFront distributions domains"
  value = {
    for key, dist in aws_cloudfront_distribution.distributions : key => dist.domain_name
  }
}

output "distribution_aliases" {
  description = "CloudFront distributions aliases"
  value = {
    for key, dist in aws_cloudfront_distribution.distributions : key => dist.aliases
  }
}

output "cname_records" {
  description = "CNAME records formatted for DNS module"
  value = {
    for key, dist in aws_cloudfront_distribution.distributions :
    key => {
      fqdn = try(local.required_distributions[key].domain, "")
      type = "CNAME"
      ttl  = 900
      data = "${dist.domain_name}."
    }
  }
}
