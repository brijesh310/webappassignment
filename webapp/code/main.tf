terraform {
  backend "s3" {
  }
  required_version = "~> 0.12"
}

provider "aws" {
  region = "eu-central-1"

  assume_role {
    role_arn = var.role
  }
  version = "~> 2"
}

provider "template" {
  version = "~> 2.1"
}

data "terraform_remote_state" "base_resources" {
  backend = "s3"
  config = {
    bucket         = var.terraform_bucket
    key            = var.terraform_base_key
    region         = var.region
    dynamodb_table = var.terraform_dynamodb
    role_arn       = var.role
  }
}

data "terraform_remote_state" "alb_resources" {
  backend = "s3"
  config = {
    bucket         = var.terraform_bucket
    key            = var.terraform_alb_key
    region         = var.region
    dynamodb_table = var.terraform_dynamodb
    role_arn       = var.role
  }
}

data "aws_ami" "webapp" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.webapp_ami_name]
  }

  owners = ["aws-marketplace"] # ["000186693631"] # Canonical
  # find some EC2 instance 
}

data "aws_ssm_parameter" "webapp_public_key" {
  name            = var.webapp_public_key
  with_decryption = true
}

locals {
  mandatory_tags = {
    Project     = var.project_name,
    Environment = var.env_designator,
  }
}