resource "aws_s3_bucket" "bucket" {
  bucket        = var.s3_bucket_name
  force_destroy = var.s3_bucket_force_destroy

  tags = merge(var.common_tags)
}

resource "aws_s3_bucket_public_access_block" "bucket_access" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_acl" "bucket-acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = var.s3_bucket_acl
}

resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = aws_s3_bucket.bucket.bucket
  policy = var.s3_bucket_policy
}

resource "aws_s3_bucket_versioning" "bucket-versioning" {
  bucket = one(aws_s3_bucket.bucket[*].bucket)

  versioning_configuration {
    status     = lookup(var.versioning, "status", null)
    mfa_delete = lookup(var.versioning, "mfa_delete", null)
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encrpytion" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = var.s3_sse_algorithm
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "bucket-cors" {
  bucket = aws_s3_bucket.bucket.id

  cors_rule {
    allowed_headers = lookup(var.cors_rule, "allowed_headers", null)
    allowed_methods = lookup(var.cors_rule, "allowed_methods", null)
    allowed_origins = lookup(var.cors_rule, "allowed_origins", null)
    expose_headers  = lookup(var.cors_rule, "expose_headers", null)
    max_age_seconds = lookup(var.cors_rule, "max_age_seconds", null)
  }
}

resource "aws_s3_bucket_logging" "bucket-logs" {
  bucket = aws_s3_bucket.bucket.id

  target_bucket = var.target_bucket
  target_prefix = var.target_prefix
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket-lifecycle" {
  bucket = aws_s3_bucket.bucket.id

  dynamic "rule" {

    for_each = var.lifecycle_rule

    content {
      id                                     = lookup(rule.value, "id", null)
      filter                                 = lookup(rule.value, "prefix", null)
      tags                                   = lookup(rule.value, "tags", null)
      abort_incomplete_multipart_upload_days = lookup(rule.value, "abort_incomplete_multipart_upload_days", null)
      status                                 = rule.value.enabled ? "Enabled" : "Disabled"

      # Max 1 block - expiration
      dynamic "expiration" {
        for_each = length(keys(lookup(rule.value, "expiration", {}))) == 0 ? [] : [lookup(rule.value, "expiration", {})]

        content {
          date                         = lookup(expiration.value, "date", null)
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }

      # Several blocks - transition
      dynamic "transition" {
        for_each = lookup(rule.value, "transition", [])

        content {
          date          = lookup(transition.value, "date", null)
          days          = lookup(transition.value, "days", null)
          storage_class = transition.value.storage_class
        }
      }

      # Max 1 block - noncurrent_version_expiration
      dynamic "noncurrent_version_expiration" {
        for_each = length(keys(lookup(rule.value, "noncurrent_version_expiration", {}))) == 0 ? [] : [lookup(rule.value, "noncurrent_version_expiration", {})]

        content {
          days = lookup(noncurrent_version_expiration.value, "days", null)
        }
      }

      # Several blocks - noncurrent_version_transition
      dynamic "noncurrent_version_transition" {
        for_each = lookup(rule.value, "noncurrent_version_transition", [])

        content {
          days          = lookup(noncurrent_version_transition.value, "days", null)
          storage_class = noncurrent_version_transition.value.storage_class
        }
      }
    }
  }
}
