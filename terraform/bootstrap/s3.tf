# Generates a random 8-character hexadecimal suffix.
#
# The value is generated during the first terraform apply and stored
# in Terraform state, so it does not change during normal future runs.
resource "random_id" "terraform_state_bucket_suffix" {
  byte_length = 4
}

locals {
  terraform_state_bucket_name = lower(
    "${var.project_name}-${var.environment}-${random_id.terraform_state_bucket_suffix.hex}-terraform-state"
  )
}


# Creates the S3 bucket that will store Terraform state files.
resource "aws_s3_bucket" "terraform_state" {
  bucket = local.terraform_state_bucket_name

  # Prevents a normal terraform destroy from accidentally deleting
  # the bucket containing the project's Terraform state.
  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name        = local.terraform_state_bucket_name
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "Terraform remote state"
  }
}


# Ensures the AWS account that owns the bucket also owns every object.
# ACLs are disabled because access is controlled with IAM policies.
resource "aws_s3_bucket_ownership_controls" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}


# Blocks all forms of public access to the Terraform state bucket.
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


# Enables default server-side encryption using an Amazon S3-managed key.
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


# Builds a bucket policy that rejects requests sent without HTTPS.
data "aws_iam_policy_document" "terraform_state" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    actions = [
      "s3:*"
    ]

    resources = [
      aws_s3_bucket.terraform_state.arn,
      "${aws_s3_bucket.terraform_state.arn}/*"
    ]

    principals {
      type = "*"

      identifiers = [
        "*"
      ]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = [
        "false"
      ]
    }
  }
}


# Attaches the HTTPS-only bucket policy.
resource "aws_s3_bucket_policy" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  policy = data.aws_iam_policy_document.terraform_state.json

  depends_on = [
    aws_s3_bucket_public_access_block.terraform_state
  ]
}