resource "aws_cloudfront_distribution" "distributions" {
  for_each = local.required_distributions

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = each.value.default_root_object
  price_class         = "PriceClass_All"
  http_version        = "http2and3"
  aliases             = [each.value.domain]

  origin {
    domain_name = each.value.origin_domain
    origin_id   = each.value.origin_domain

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_read_timeout      = 30
      origin_keepalive_timeout = 5
    }
  }

  dynamic "origin" {
    for_each = each.value.additional_origins
    content {
      domain_name = origin.value.domain_name
      origin_id   = origin.value.origin_id

      dynamic "custom_origin_config" {
        for_each = lookup(origin.value, "custom_origin_config", false) ? [1] : []
        content {
          http_port                = 80
          https_port               = 443
          origin_protocol_policy   = lookup(origin.value, "origin_protocol", "https-only")
          origin_ssl_protocols     = ["TLSv1.2"]
          origin_read_timeout      = 30
          origin_keepalive_timeout = 5
        }
      }
    }
  }

  default_cache_behavior {
    allowed_methods = coalesce(each.value.default_allowed_methods, ["GET", "HEAD", "OPTIONS"])
    cached_methods  = ["GET", "HEAD"]
    target_origin_id = (
      each.value.default_cache_behavior_target_origin_id != null ? each.value.default_cache_behavior_target_origin_id :
      each.value.origin_domain
    )
    viewer_protocol_policy = "allow-all"
    compress               = true

    cache_policy_id = coalesce(
      each.value.default_cache_policy_id,
      aws_cloudfront_cache_policy.use_origin_headers.id
    )

    origin_request_policy_id = each.value.default_origin_request_policy_id != null ? each.value.default_origin_request_policy_id : null

    response_headers_policy_id = each.value.default_response_headers_policy_id != null ? each.value.default_response_headers_policy_id : null

    dynamic "function_association" {
      for_each = each.value.viewer_request_function != null ? [1] : []
      content {
        event_type   = "viewer-request"
        function_arn = local.cloudfront_functions[each.value.viewer_request_function]
      }
    }
  }

  # Ordered cache behaviors from the configuration
  dynamic "ordered_cache_behavior" {
    for_each = each.value.ordered_cache_behaviors

    content {
      path_pattern     = ordered_cache_behavior.value.path_pattern
      allowed_methods  = lookup(ordered_cache_behavior.value, "allowed_methods", ["GET", "HEAD", "OPTIONS"])
      cached_methods   = lookup(ordered_cache_behavior.value, "cached_methods", ["GET", "HEAD"])
      target_origin_id = ordered_cache_behavior.value.target_origin_id

      viewer_protocol_policy = lookup(ordered_cache_behavior.value, "viewer_protocol_policy", "allow-all")
      compress               = lookup(ordered_cache_behavior.value, "compress", true)

      cache_policy_id            = lookup(ordered_cache_behavior.value, "cache_policy_id", null)
      origin_request_policy_id   = lookup(ordered_cache_behavior.value, "origin_request_policy_id", null)
      response_headers_policy_id = lookup(ordered_cache_behavior.value, "response_headers_policy_id", null)

      dynamic "function_association" {
        for_each = ordered_cache_behavior.value.viewer_request_function != null ? [1] : []
        content {
          event_type   = "viewer-request"
          function_arn = local.cloudfront_functions[ordered_cache_behavior.value.viewer_request_function]
        }
      }
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.certificate_arns[each.value.certificate_key]
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
