# General variables pertaining to the account etc.
variable "region" {
  description = "The main region to use"
  type        = string
  default     = "eu-central-1"
}

variable "region_name" {
  description = "A variable telling the region for naming purposes"
  type        = string
  default     = "ec1"
}

variable "account_number" {
  description = "The account we are currently working on."
  type        = string
}

variable "role" {
  description = "The role to use for this terraforming"
  type        = string

}

variable "env_designator" {
  description = "Something to differentiate between environments (dev, test, prod, etc.)"
  type        = string
}

# Generic variables
variable "project_name" {
  description = "Name of the project/team"
  type        = string
  default     = "webapp"
}
# +++++++++++++++++++++++++++++++++++++++++++++++++

variable "terraform_bucket" {
  description = "Terraform bucket where located Terraform state"
  type        = string
}

variable "terraform_dynamodb" {
  description = "Name of the DynamoDB table that is in use by Terraform"
  type        = string
  default     = "test-terraform-statelock"
}

variable "terraform_base_key" {
  description = "Name of the key for Base"
  type        = string
}

variable "terraform_alb_key" {
  description = "Name of the key for ALB"
  type        = string
}
# +++++++++++++++++++++++++++++++++++++++++++++++++

variable "webapp_domain" {
  description = "webapp domain that ALB rule will use"
  type        = string
}

variable "webapp_ami_name" {
  description = "webapp AMI name"
  type        = string
}

variable "webapp_sg_ssh" {
  description = "List of IPs allowed connect to webapp through SSH"
  type        = list(string)
}

variable "webapp_public_key" {
  description = "SSM parameter where webapp EC2 public key is located"
  type        = string
}

variable "webapp_instance_type" {
  description = "EC2 instance type for webapp"
  type        = string
  default     = "t3.medium"
}

variable "webapp_volume_size" {
  description = "EC2 instance volume size"
  type        = string
  default     = 15
}