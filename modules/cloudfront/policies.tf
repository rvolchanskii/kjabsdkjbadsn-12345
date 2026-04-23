# Custom Cache Policy - CachingStaticIgnoreCacheControl
resource "aws_cloudfront_cache_policy" "caching_static" {
  name        = "CachingStaticIgnoreCacheControl"
  default_ttl = 31536000
  max_ttl     = 31536000
  min_ttl     = 31536000

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "none"
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

# Custom Cache Policy - UseOriginCacheControlHeaders
resource "aws_cloudfront_cache_policy" "use_origin_cache_control_headers" {
  name        = "UseOriginCacheControlHeaders"
  comment     = "Policy for origins that return Cache-Control headers. Query strings are not included in the cache key."
  default_ttl = 0
  max_ttl     = 31536000
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    cookies_config {
      cookie_behavior = "all"
    }

    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["x-method-override", "origin", "host", "x-http-method", "x-http-method-override"]
      }
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

# Custom Cache Policy - UseOriginCacheControlHeadersExceptHost
resource "aws_cloudfront_cache_policy" "use_origin_headers" {
  name        = "UseOriginCacheControlHeadersExceptHost"
  default_ttl = 0
  max_ttl     = 31536000
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    cookies_config {
      cookie_behavior = "all"
    }

    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["Origin", "x-method-override", "x-http-method", "x-http-method-override"]
      }
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }
}

# Custom Cache Policy - UseOriginCacheControlHeadersExceptHost-QueryStringsV
resource "aws_cloudfront_cache_policy" "use_origin_headers_query_string_v" {
  name        = "UseOriginCacheControlHeadersExceptHost-QueryStringsV"
  default_ttl = 0
  max_ttl     = 31536000
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    cookies_config {
      cookie_behavior = "all"
    }

    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["Origin", "x-method-override", "x-http-method", "x-http-method-override"]
      }
    }

    query_strings_config {
      query_string_behavior = "whitelist"
      query_strings {
        items = ["v"]
      }
    }
  }
}

# Custom Cache Policy - UseOriginCacheControlHeadersExceptHost-XImageFormat
resource "aws_cloudfront_cache_policy" "caching_optimized_x_image_format" {
  name        = "CachingOptimized-XImageFormat"
  default_ttl = 86400
  max_ttl     = 31536000
  min_ttl     = 1

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true

    cookies_config {
      cookie_behavior = "none"
    }

    headers_config {
      header_behavior = "whitelist"
      headers {
        items = ["x-image-format"]
      }
    }

    query_strings_config {
      query_string_behavior = "none"
    }
  }
}


# Custom Response Headers Policy - RemoveNEL
resource "aws_cloudfront_response_headers_policy" "remove_nel" {
  name = "RemoveNEL"

  remove_headers_config {
    items {
      header = "nel"
    }
    items {
      header = "report-to"
    }
  }

  security_headers_config {
  }
}

# Custom Response Headers Policy - RemoveNELAndCookies
resource "aws_cloudfront_response_headers_policy" "remove_nel_cookies" {
  name = "RemoveNELAndCookies"

  remove_headers_config {
    items {
      header = "nel"
    }
    items {
      header = "report-to"
    }
    items {
      header = "set-cookie"
    }
  }

  security_headers_config {
  }
}

# Custom Response Headers Policy - RemoveNELAndCacheHost
resource "aws_cloudfront_response_headers_policy" "remove_nel_cache_host" {
  name = "RemoveNELAndCacheHost"

  remove_headers_config {
    items {
      header = "nel"
    }
    items {
      header = "report-to"
    }
    items {
      header = "cache-host"
    }
  }

  security_headers_config {
  }
}

# Custom Response Headers Policy - RemoveNELAndCookiesAndCacheHost
resource "aws_cloudfront_response_headers_policy" "remove_nel_cookies_cache_host" {
  name = "RemoveNELAndCookiesAndCacheHost"

  remove_headers_config {
    items {
      header = "nel"
    }
    items {
      header = "report-to"
    }
    items {
      header = "set-cookie"
    }
    items {
      header = "cache-host"
    }
  }

  security_headers_config {
  }
}