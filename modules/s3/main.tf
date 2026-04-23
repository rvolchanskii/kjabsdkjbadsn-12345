resource "aws_s3_bucket" "cdn_bucket" {
  bucket = var.cdn_bucket_name

  tags = var.default_tags
}

resource "aws_s3_bucket_ownership_controls" "cdn_bucket_ownership" {
  bucket = aws_s3_bucket.cdn_bucket.bucket

  rule {
    object_ownership = var.cdn_bucket_ownership
  }
}

resource "aws_s3_bucket_public_access_block" "cdn_bucket_access" {
  bucket = aws_s3_bucket.cdn_bucket.bucket

  block_public_acls       = var.cdn_bucket_block_public_acls
  block_public_policy     = var.cdn_bucket_block_public_policy
  ignore_public_acls      = var.cdn_bucket_ignore_public_acls
  restrict_public_buckets = var.cdn_bucket_restrict_public_buckets
}
