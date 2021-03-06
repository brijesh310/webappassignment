resource "aws_key_pair" "webapp" {
  key_name   = "${var.region_name}-${var.env_designator}-webapp-keys"
  public_key = data.aws_ssm_parameter.webapp_public_key.value
  tags       = local.mandatory_tags
}