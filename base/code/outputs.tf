output "main_vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "subnet_jenkins_ids" {
  value = aws_subnet.subnet_private.*.id
}

output "private_subnet_ids" {
  value = aws_subnet.subnet_private.*.id
}

output "public_subnet_ids" {
  value = aws_subnet.subnet_public.*.id
}

output "base_kms_arn" {
  value = aws_kms_key.base_kms.arn
}

output "s3_access_log_bucket" {
  value = aws_s3_bucket.s3_access_logging.id
}

output "ec2_generic_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_generic.name
}

output "tools_bucket_name" {
  value = aws_s3_bucket.tools_x_webapp_test_bank.bucket
}