provider "aws" {
  region = "eu-west-2"
}

resource "aws_cloudfront_distribution" "cdf1" {
  origin {
    domain_name = "bartman-websiteproject.s3-website.eu-west-2.amazonaws.com"
    origin_id   = "S3-bartman-websiteproject"
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id       = "S3-bartman-websiteproject"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
