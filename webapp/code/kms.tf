resource "aws_kms_key" "webapp_kms" {
  description = "webapp KMS"
  tags = merge(
    local.mandatory_tags,
    map("Name", "${var.region_name}-${var.env_designator}-webapp-ec2-kms")
  )
}

resource "aws_kms_alias" "webapp_kms_alias" {
  name          = "alias/${var.region_name}-${var.env_designator}-webapp-ec2-kms"
  target_key_id = aws_kms_key.webapp_kms.key_id
}