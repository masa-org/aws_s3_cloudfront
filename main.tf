### S3

data "aws_iam_policy_document" "www" {
  statement {
    sid = "Allow CloudFront"
    effect = "Allow"
    principals {
        type = "AWS"
        identifiers = [aws_cloudfront_origin_access_identity.www.iam_arn]
    }
    actions = [
        "s3:GetObject"
    ]

    resources = [
        "${aws_s3_bucket.www.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "bucket" {
    bucket = aws_s3_bucket.www.id
    policy = data.aws_iam_policy_document.www.json
}

resource "aws_s3_bucket" "www" {
  bucket = "${var.prefix}-bucket"
}

resource "aws_s3_bucket_ownership_controls" "www" {
  bucket = aws_s3_bucket.www.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "www" {
  depends_on = [aws_s3_bucket_ownership_controls.www]

  bucket = aws_s3_bucket.www.id
  acl    = "private"
}

resource "aws_s3_bucket_website_configuration" "www" {
  bucket = aws_s3_bucket.www.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# index.html
resource "aws_s3_object" "index_page" {
  bucket = aws_s3_bucket.www.id
  key = "index.html"
  content_type = "text/html"
  etag = filemd5("index.html")
  source = "index.html"
}

# error.html
resource "aws_s3_object" "error_page" {
  bucket = aws_s3_bucket.www.id
  key = "error.html"
  content_type = "text/html"
  etag = filemd5("error.html")
  source = "error.html"
}

### Cloud Front

resource "aws_cloudfront_distribution" "www" {
    origin {
        domain_name = aws_s3_bucket.www.bucket_regional_domain_name
        origin_id = aws_s3_bucket.www.id
        s3_origin_config {
          origin_access_identity = aws_cloudfront_origin_access_identity.www.cloudfront_access_identity_path
        }
    }

    enabled =  true

    default_root_object = "index.html"

    default_cache_behavior {
        allowed_methods = [ "GET", "HEAD" ]
        cached_methods = [ "GET", "HEAD" ]
        target_origin_id = aws_s3_bucket.www.id

        forwarded_values {
            query_string = false

            cookies {
              forward = "none"
            }
        }

        viewer_protocol_policy = "redirect-to-https"
        min_ttl = 0
        default_ttl = 3600
        max_ttl = 86400
    }

    restrictions {
      geo_restriction {
          restriction_type = "whitelist"
          locations = [ "JP" ]
      }
    }
    viewer_certificate {
        cloudfront_default_certificate = true
    }
}

resource "aws_cloudfront_origin_access_identity" "www" {}
