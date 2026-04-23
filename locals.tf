locals {
  distributions_config = yamldecode(file("${path.root}/cloudfront_distributions.yaml"))
  domains_config       = yamldecode(file("${path.root}/cloudfront_domains.yaml"))

  # Generate certificate domains based on distributions and organizations
  certificate_domains = merge([
    for dist_key, dist in local.distributions_config.distributions : merge([
      for org_key, org in local.domains_config.organizations : {
        for domain in org.domains :
        "${dist_key}_${org_key}_${domain}" => {
          domain = "${dist.name}.${domain}"
        }
      }
      if !contains(lookup(dist, "exclude_orgs", []), org_key)
    ]...)
  ]...)
}
