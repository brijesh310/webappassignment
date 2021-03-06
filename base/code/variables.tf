# General variables pertaining to the account etc.
variable "region" {
  type        = string
  description = "The main region to use"
  default     = "eu-central-1"
}

variable "region_name" {
  type        = string
  description = "A variable telling the region for naming purposes"
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
  type        = string
  description = "Something to differentiate between environments (dev, test, prod, etc.)"
}

# Generic variables
variable "project_name" {
  type        = string
  description = "Name of the project/team"

  default = "webapp"
}
# +++++++++++++++++++++++++++++++++++++++++++++++++
variable "vpc_cidr" {
  type = string

  default = "10.21.2.0/24"
}

# 
# Public subnets
#
variable "public_subnets_cidr" {
  type = list(string)

  default = ["10.21.2.16/28", "10.21.2.32/28", "10.21.2.48/28"]
}

#
# Private subnets
#
variable "private_subnets_cidr" {
  type = list(string)

  default = ["10.21.2.64/27", "10.21.2.96/27", "10.21.2.128/27"]
}

variable "elk_private_subnet_cidr" {
  type        = string
  description = "CIDR for ELK private subnet"
}

#
# NAT EIP 
#
/*
variable "eip" {
  type        = list(string)
  description = "Elastic IP for NAT gateway "
}
*/
#+++++++++++++++++++++++++++++++++++++++++++++++++

# 
# Workspace TGW Id, that will be connected with EKS
#
variable "workspace_tgw_id" {
  type        = string
  description = "Workspace Id that needs to be connected to EKS"
}
# Workspace 
variable "workspace_tgw_cidr" {
  description = "The CIDR block of the workspace, used to route to the TGW above"
  type        = string
}


# webapp variables
variable "tools_bucket_name" {
  description = "Name of the bucket were Tools source will be stored"
  type = string
}