data "aws_iam_policy_document" "bucket-tls-policy-document" {

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

    actions = ["S3:*"]

    resources = [
      "${aws_s3_bucket.bucket.arn}/*",
      aws_s3_bucket.bucket.arn
    ]
  }
}