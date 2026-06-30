data "aws_iam_policy_document" "bucket-tls-policy-document" {
  # Merge any caller-supplied policy with the mandatory TLS-deny so the
  # SecureTransport guard can't be dropped by passing a custom s3_bucket_policy.
  source_policy_documents = (var.s3_bucket_policy == null || var.s3_bucket_policy == "") ? [] : [var.s3_bucket_policy]

  statement {
    sid = "SecureTransport"

    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }

    #condition {
    #test = "NumericLessThan"
    #variable = "s3:TlsVersion"
    #values = [1.2]
    #}

    actions = ["s3:*"]

    resources = [
      "${aws_s3_bucket.bucket.arn}/*",
      aws_s3_bucket.bucket.arn
    ]
  }
}