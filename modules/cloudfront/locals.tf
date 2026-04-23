locals {
  cloudfront_functions = {
    "return_404"     = aws_cloudfront_function.return_404.arn
    "normalize_webp" = aws_cloudfront_function.normalize_webp.arn
  }
}

locals {
  all_distributions = flatten([
    for dist_key, dist in var.distributions_config.distributions : [
      for org_key, org in var.domains_config.organizations : [
        for domain in org.domains : {
          key                                     = "${dist_key}_${org_key}_${domain}"
          dist_key                                = dist_key
          org_key                                 = org_key
          domain                                  = "${dist.name}.${domain}"
          origin_domain                           = dist.origin_domain
          origin_protocol                         = "https-only"
          default_root_object                     = try(dist.org_overrides[org_key].default_root_object, dist.default_root_object, null)
          exclude_orgs                            = lookup(dist, "exclude_orgs", [])
          certificate_key                         = "${dist_key}_${org_key}_${domain}"
          additional_origins                      = lookup(dist, "additional_origins", [])
          default_cache_behavior_target_origin_id = lookup(dist, "default_cache_behavior_target_origin_id", null)
          ordered_cache_behaviors = [
            for behavior in try(
              dist.org_overrides[org_key].ordered_cache_behaviors,
              lookup(dist, "ordered_cache_behaviors", [])
              ) : merge(behavior, {
                # Convert policy names to IDs
                cache_policy_id            = lookup(behavior, "cache_policy", null) != null ? local.cache_policy_ids[behavior.cache_policy] : null
                origin_request_policy_id   = lookup(behavior, "origin_request_policy", null) != null ? local.origin_request_policy_ids[behavior.origin_request_policy] : null
                response_headers_policy_id = lookup(behavior, "response_headers_policy", null) != null ? local.response_headers_policy_ids[behavior.response_headers_policy] : null
                viewer_request_function    = lookup(behavior, "viewer_request_function", null)
            })
          ]
          default_allowed_methods = lookup(dist, "default_allowed_methods", null)

          # Policies for default cache behavior
          default_cache_policy_id            = try(dist.default_cache_behavior.cache_policy, null) != null ? local.cache_policy_ids[dist.default_cache_behavior.cache_policy] : null
          default_origin_request_policy_id   = try(dist.default_cache_behavior.origin_request_policy, null) != null ? local.origin_request_policy_ids[dist.default_cache_behavior.origin_request_policy] : null
          default_response_headers_policy_id = try(dist.default_cache_behavior.response_headers_policy, null) != null ? local.response_headers_policy_ids[dist.default_cache_behavior.response_headers_policy] : null
          viewer_request_function            = lookup(dist, "viewer_request_function", null)
          add_s3_origin_fallback             = lookup(dist, "add_s3_origin_fallback", false)
        }
      ]
      if !contains(lookup(dist, "exclude_orgs", []), org_key)
    ]
  ])

  required_distributions = {
    for dist in local.all_distributions : dist.key => dist
  }
}
