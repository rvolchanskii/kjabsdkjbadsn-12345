# Collect all unique policy names from the configuration
locals {
  # Extract all cache policies from the configuration
  all_cache_policy_names = distinct(compact(flatten([
    # From default behaviors
    [for dist_key, dist in var.distributions_config.distributions :
      lookup(dist, "cache_policy", null)
    ],
    # From default_cache_behavior
    [for dist_key, dist in var.distributions_config.distributions :
      try(dist.default_cache_behavior.cache_policy, null)
    ],
    # From ordered behaviors
    [for dist_key, dist in var.distributions_config.distributions :
      [for behavior in lookup(dist, "ordered_cache_behaviors", []) :
        lookup(behavior, "cache_policy", null)
      ]
    ],
    # From org overrides
    [for dist_key, dist in var.distributions_config.distributions :
      [for org_key, org_override in lookup(dist, "org_overrides", {}) :
        [for behavior in lookup(org_override, "ordered_cache_behaviors", []) :
          lookup(behavior, "cache_policy", null)
        ]
      ]
    ]
  ])))

  # Extract all origin request policies from the configuration
  all_origin_request_policy_names = distinct(compact(flatten([
    # From default behaviors
    [for dist_key, dist in var.distributions_config.distributions :
      lookup(dist, "origin_request_policy", null)
    ],
    # From default_cache_behavior
    [for dist_key, dist in var.distributions_config.distributions :
      try(dist.default_cache_behavior.origin_request_policy, null)
    ],
    # From ordered behaviors
    [for dist_key, dist in var.distributions_config.distributions :
      [for behavior in lookup(dist, "ordered_cache_behaviors", []) :
        lookup(behavior, "origin_request_policy", null)
      ]
    ],
    # From org overrides
    [for dist_key, dist in var.distributions_config.distributions :
      [for org_key, org_override in lookup(dist, "org_overrides", {}) :
        [for behavior in lookup(org_override, "ordered_cache_behaviors", []) :
          lookup(behavior, "origin_request_policy", null)
        ]
      ]
    ]
  ])))

  # Extract all response headers policies from the configuration
  all_response_headers_policy_names = distinct(compact(flatten([
    # From default behaviors
    [for dist_key, dist in var.distributions_config.distributions :
      lookup(dist, "response_headers_policy", null)
    ],
    # From default_cache_behavior
    [for dist_key, dist in var.distributions_config.distributions :
      try(dist.default_cache_behavior.response_headers_policy, null)
    ],
    # From ordered behaviors
    [for dist_key, dist in var.distributions_config.distributions :
      [for behavior in lookup(dist, "ordered_cache_behaviors", []) :
        lookup(behavior, "response_headers_policy", null)
      ]
    ],
    # From org overrides
    [for dist_key, dist in var.distributions_config.distributions :
      [for org_key, org_override in lookup(dist, "org_overrides", {}) :
        [for behavior in lookup(org_override, "ordered_cache_behaviors", []) :
          lookup(behavior, "response_headers_policy", null)
        ]
      ]
    ]
  ])))
}

# Filter only managed policies (starting with "Managed-")
locals {
  managed_cache_policy_names = [
    for name in local.all_cache_policy_names : name
    if can(regex("^Managed-", name))
  ]

  # AWS managed cache policy IDs are stable; keep them locally to avoid
  # relying on data source refresh ordering when the distributions set changes.
  managed_cache_policy_ids_static = {
    "Managed-CachingOptimized"                       = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    "Managed-CachingDisabled"                        = "413fbbce-d276-4b83-9b85-191517f1d8c6"
    "Managed-CachingOptimizedForUncompressedObjects" = "b2884449-e4de-46a7-ac36-70bc7f1ddd6d"
  }

  managed_origin_request_policy_names = [
    for name in local.all_origin_request_policy_names : name
    if can(regex("^Managed-", name))
  ]

  # AWS managed origin request policy IDs are stable; keep them locally to avoid
  # relying on data source refresh ordering when the distributions set changes.
  managed_origin_request_policy_ids_static = {
    "Managed-AllViewer"                 = "216adef6-5c7f-47e4-b989-5492eafa07d3"
    "Managed-AllViewerExceptHostHeader" = "b689b0a8-53d0-40ab-baf2-68738e2966ac"
    "Managed-CORS-CustomOrigin"         = "59781a5b-3903-41f3-afcb-af62929ccde1"
    "Managed-CORS-S3Origin"             = "acba4595-bd28-49b8-b9fe-13317c0390fa"
    "Managed-UserAgentRefererHeaders"   = "33f46ac6-0d47-4a45-865b-55dff9d784f2"
  }

  managed_response_headers_policy_names = [
    for name in local.all_response_headers_policy_names : name
    if can(regex("^Managed-", name))
  ]
}

# Dynamically create data sources for all used cache policies
data "aws_cloudfront_cache_policy" "dynamic" {
  for_each = toset([
    for name in local.managed_cache_policy_names : name
    if !contains(keys(local.managed_cache_policy_ids_static), name)
  ])

  name = each.value
}

# Dynamically create data sources for all used origin request policies
data "aws_cloudfront_origin_request_policy" "dynamic" {
  for_each = toset([
    for name in local.managed_origin_request_policy_names : name
    if !contains(keys(local.managed_origin_request_policy_ids_static), name)
  ])

  name = each.value
}

# Dynamically create data sources for all used response headers policies
data "aws_cloudfront_response_headers_policy" "dynamic" {
  for_each = toset(local.managed_response_headers_policy_names)
  name     = each.value
}

# Create mapping for convenient access to policy IDs
locals {
  cache_policy_ids = merge(
    # Always include static IDs for AWS managed policies; they are stable and safe to
    # keep even if not referenced in the current configuration snapshot.
    local.managed_cache_policy_ids_static,
    {
      for name, policy in data.aws_cloudfront_cache_policy.dynamic : name => policy.id
    },
    {
      # Custom policies
      "CachingStaticIgnoreCacheControl"                      = aws_cloudfront_cache_policy.caching_static.id
      "UseOriginCacheControlHeaders"                         = aws_cloudfront_cache_policy.use_origin_cache_control_headers.id
      "UseOriginCacheControlHeadersExceptHost"               = aws_cloudfront_cache_policy.use_origin_headers.id
      "UseOriginCacheControlHeadersExceptHost-QueryStringsV" = aws_cloudfront_cache_policy.use_origin_headers_query_string_v.id
      "CachingOptimized-XImageFormat"                        = aws_cloudfront_cache_policy.caching_optimized_x_image_format.id
    }
  )

  origin_request_policy_ids = merge(
    # Prefer static IDs for AWS managed policies to avoid state refresh quirks
    local.managed_origin_request_policy_ids_static,
    {
      for name, policy in data.aws_cloudfront_origin_request_policy.dynamic : name => policy.id
    }
  )

  response_headers_policy_ids = merge(
    {
      for name, policy in data.aws_cloudfront_response_headers_policy.dynamic : name => policy.id
    },
    {
      # Custom policies
      "RemoveNEL"                       = aws_cloudfront_response_headers_policy.remove_nel.id
      "RemoveNELAndCookies"             = aws_cloudfront_response_headers_policy.remove_nel_cookies.id
      "RemoveNELAndCacheHost"           = aws_cloudfront_response_headers_policy.remove_nel_cache_host.id
      "RemoveNELAndCookiesAndCacheHost" = aws_cloudfront_response_headers_policy.remove_nel_cookies_cache_host.id
    }
  )
}
