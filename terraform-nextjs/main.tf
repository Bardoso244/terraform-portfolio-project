provider "aws" {
  region = "eu-west-2"
}

# Static content bucket

resource "aws_s3_bucket" "nextjs-website-bucket" {
  bucket = "nextjs-portfolio-br-website"
    
}

# Bucket ownership controls - this ensures bucket owner has full control 
# over objects uploaded to the bucket


resource "aws_s3_bucket_ownership_controls" "bucket-ownership-controls" {
  bucket = aws_s3_bucket.nextjs-website-bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Public access block removal

resource "aws_s3_bucket_public_access_block" "website_bucket_block" {
  bucket = aws_s3_bucket.nextjs-website-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Bucket ACL - allowing public read on the bucket

resource "aws_s3_bucket_acl" "nextjs_bucket_acl" {
  bucket = aws_s3_bucket.nextjs-website-bucket.id

  acl = "public-read"
  depends_on = [ 
    aws_s3_bucket_ownership_controls.bucket-ownership-controls,
    aws_s3_bucket_public_access_block.website_bucket_block
   ]  
}

# Bucket policy - allowing public read on the bucket

resource "aws_s3_bucket_policy" "nextjs_bucket_policy" {
  bucket = aws_s3_bucket.nextjs-website-bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::nextjs-portfolio-br-website/*"
      },
    ]
  })
  
}

# Origin access identity - allowing Cloudfront to access the bucket

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "OAI access for nextjs-portfolio-br-website"
}
# Cloudfront distribution

resource "aws_cloudfront_distribution" "cdf1" {
  origin {
    domain_name = aws_s3_bucket.nextjs-website-bucket.bucket_regional_domain_name
    origin_id = "s3-nextjs-portfolio-br-website"
    
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }
    enabled = true
    comment = "nextjs-portfolio-br-website"
    default_root_object = "index.html"
  
  



  default_cache_behavior {
  
    target_origin_id       = "s3-nextjs-portfolio-br-website"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
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
