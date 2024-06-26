variable "common_tags" {
  description = "Set the common tags that will be populated to all AWS resources"
  type        = map(string)
}

variable "s3_bucket_acl" {
  description = "Set the bucket access control list"
  default     = "private"
}

variable "s3_bucket_force_destroy" {
  description = "Allow the bucket to be destroyed after creation"
  default     = false
}

variable "s3_bucket_name" {
  description = "Set the name for the S3 bucket"
}

variable "s3_bucket_ownership" {
  description = "Sets ownership of objects uploaded to the bucket and to disable/enable ACLs."
  default = "BucketOwnerEnforced"
}

variable "s3_bucket_policy" {
  description = "You can provide a custom bucket policy with this variable"
  default     = null
}

variable "s3_sse_algorithm" {
  description = "Set the server side encryption on the bucket, choose between AES or KMS"
  default     = "AES256"
}

variable "block_public_acls" {
  default = false
}

variable "block_public_policy" {
  default = false
}

variable "ignore_public_acls" {
  default = false
}

variable "restrict_public_buckets" {
  default = false
}

variable "lifecycle_rule" {
  description = "List of maps containing configuration of object lifecycle management."
  type        = any
  default     = {}
}

variable "versioning" {
  description = "Map containing versioning configuration."
  type        = map(string)
  default     = {}
}

variable "cors_rule" {
  description = "List of maps containing CORS configuration."
  type        = any
  default     = {}
}

variable "logging" {
  default = {}
}