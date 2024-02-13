output "s3_bucket_info" {
  value = <<EOF
Domain Name:           ${aws_s3_bucket.www.bucket_domain_name}
Regional Domain Name : ${aws_s3_bucket.www.bucket_regional_domain_name}
Hosted Zone ID :       ${aws_s3_bucket.www.hosted_zone_id}
EOF
}

output "s3_cloudfront_info" {
  value = <<EOF
Domain Name:    ${aws_cloudfront_distribution.www.domain_name}
Hosted Zone ID: ${aws_cloudfront_distribution.www.hosted_zone_id}
EOF
}
