module "s3" {
  source = "./modules/s3"

  cdn_bucket_name                    = "aws-taxi-cdn-cloudfront"
  cdn_bucket_ownership               = "ObjectWriter"
  cdn_bucket_block_public_acls       = true
  cdn_bucket_block_public_policy     = true
  cdn_bucket_ignore_public_acls      = true
  cdn_bucket_restrict_public_buckets = true
}

module "acm" {
  for_each = local.certificate_domains

  source = "../terraform/shared_modules/acm-validated"

  domain_name               = each.value.domain
  subject_alternative_names = []

  providers = {
    aws     = aws.us-east-1
    dns2api = dns2api
  }
}

module "cloudfront" {
  source               = "./modules/cloudfront"
  distributions_config = local.distributions_config
  domains_config       = local.domains_config
  certificate_arns = {
    for key, cert in module.acm : key => cert.certificate_arn
  }

  depends_on = [module.acm]
}

module "dns_cname" {
  source = "./modules/dns"

  records     = module.cloudfront.cname_records
  description = "CloudFront distribution CNAME records"
}
