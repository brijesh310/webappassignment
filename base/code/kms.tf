resource "aws_kms_key" "base_kms" {
  description = "Base KMS"
  tags = {
    Name        = "${var.region_name}-${var.env_designator}-base-kms",
    Project     = var.project_name,
    Environment = var.env_designator,
    Output      = "1"
  }
}

resource "aws_kms_alias" "base_kms_alias" {
  name          = "alias/${var.region_name}-${var.env_designator}-base-kms"
  target_key_id = aws_kms_key.base_kms.key_id
}
