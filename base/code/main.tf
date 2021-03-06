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

# We need to create a vault for backups in Stockholm.
provider "aws" {
  alias  = "backup"
  region = "eu-north-1"

  assume_role {
    role_arn = var.role
  }
  version = "~> 2"
}

locals {
  availability_zones = [
    "${var.region}a",
    "${var.region}b",
    "${var.region}c"
  ]
  zones = [
    "1a",
    "1b",
    "1c"
  ]
}
