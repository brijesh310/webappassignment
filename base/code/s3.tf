#
# SSM run logs?
#
resource "aws_s3_bucket" "ssm_run_logs" {
  bucket = "${var.region_name}-${var.env_designator}-webapp-ssm-run"
  acl    = "private"

  versioning {
    enabled = false
  }

  logging {
    target_bucket = aws_s3_bucket.s3_access_logging.bucket
    target_prefix = "ssm_run_logs"
  }
}

# This bucket has these settings.
resource "aws_s3_bucket_public_access_block" "ssm_run_logs" {
  bucket                  = aws_s3_bucket.ssm_run_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "s3_access_logging" {
  bucket = "${var.region_name}-${var.env_designator}-webapp-s3-serveraccesslog"
  acl    = "log-delivery-write"

  versioning {
    enabled = false
  }
}

# This bucket has these settings.
resource "aws_s3_bucket_public_access_block" "s3_access_logging" {
  bucket                  = aws_s3_bucket.s3_access_logging.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#
# A website hosting bucket, possibly connected to CloudFront.
# If so we should move this declaration
resource "aws_s3_bucket" "tools_x_webapp_test_bank" {
  bucket = var.tools_bucket_name
  acl    = "private"
  website {
    index_document = "index.html"
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  logging {
    target_bucket = aws_s3_bucket.s3_access_logging.bucket
    target_prefix = "webapp-test"
  }
}

# Assign the policy to the bucket
resource "aws_s3_bucket_policy" "tools_x_webapp_test_bank" {
  bucket = aws_s3_bucket.tools_x_webapp_test_bank.bucket
  policy = data.aws_iam_policy_document.tools_x_webapp_test_bank.json
}

# A policy
data "aws_iam_policy_document" "tools_x_webapp_test_bank" {
  statement {
    #
    # I doubt that this is correct! But it is copied from
    # the original, I also doubt that the attached policy works...
    #
    actions = [
    "s3:*"]
    resources = [
    "${aws_s3_bucket.tools_x_webapp_test_bank.arn}/*"]
    principals {
      identifiers = [
      "*"]
      type = "AWS"
    }
    condition {
      test = "IpAddress"
      values = [
        "35.158.120.94/32",
        "54.171.56.213/32",
        "194.103.235.67/32",
        "82.99.42.71/32",
        "83.253.7.52/32"
      ]
      variable = "aws:SourceIp"
    }
  }
}

# This bucket seems to be created for AWS Config
# It has a broken configuration and have not been used
resource "aws_s3_bucket" "webapp_s3_mobsfreports_backup" {
  bucket = "${var.region_name}-${var.env_designator}-webapp-s3-mobsfreports-backup"
  acl    = "private"

  versioning {
    enabled = false
  }

  logging {
    target_bucket = aws_s3_bucket.s3_access_logging.bucket
    target_prefix = "mobfsreports-backup"
  }
}

# This bucket has these settings.
resource "aws_s3_bucket_public_access_block" "webapp_s3_mobsfreports_backup" {
  bucket                  = aws_s3_bucket.webapp_s3_mobsfreports_backup.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Jenkins S3 bucket
# We include backup bucket here as it will be needed for restore Jenkins cluster
resource "aws_s3_bucket" "jenkins_backup" {
  bucket = "${var.region_name}-${var.env_designator}-s3-jenkinsconfigbackup"
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  logging {
    target_bucket = aws_s3_bucket.s3_access_logging.bucket
    target_prefix = "webapp-test"
  }
}

# This bucket has these settings.
resource "aws_s3_bucket_public_access_block" "jenkins_backup" {
  bucket                  = aws_s3_bucket.jenkins_backup.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}