resource "aws_instance" "webapp" {
  ami           = data.aws_ami.webapp.id
  instance_type = var.webapp_instance_type
  vpc_security_group_ids = [
  aws_security_group.webapp.id]
  subnet_id                   = data.terraform_remote_state.base_resources.outputs.private_subnet_ids[0]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.webapp.key_name
  iam_instance_profile        = data.terraform_remote_state.base_resources.outputs.ec2_generic_instance_profile_name
  user_data                   = data.template_file.webapp_user_data.rendered

  monitoring = true
  root_block_device {
    volume_type = "gp2"
    volume_size = var.webapp_volume_size
    encrypted   = true
    kms_key_id  = aws_kms_key.webapp_kms.id
  }

  volume_tags = merge(
    local.mandatory_tags,
    map(
      "Name", "${var.region_name}-${var.env_designator}-webapp-volume"
    )
  )

  tags = merge(
    local.mandatory_tags,
    map(
      "Name", "${var.region_name}-${var.env_designator}-webapp-ec2",
      "webappDailyBackup", "true",
    "webappWeeklyBackup", "true")
  )

  timeouts {
    create = "3m"
    delete = "5m"
  }

  lifecycle {
    ignore_changes = [
      root_block_device
    ]
  }
}

# User data
data "template_file" "webapp_user_data" {
  template = file("../../base/scripts/ec2_generic_userdata.sh")
}
