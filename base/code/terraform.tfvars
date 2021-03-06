account_number          = "xxxxxxxxxxxx"
role                    = "arn:aws:iam::xxxxxxxxxxxx:role/admin"
env_designator          = "prod"
workspace_tgw_id        = "tgw-0e168c2ed697d3286" # --> correct TGW "tgw-0565a68ca59a45292"
workspace_tgw_cidr      = "10.25.0.0/16"
vpc_cidr                = "10.25.2.0/24"
elk_private_subnet_cidr = "10.25.2.160/28"
public_subnets_cidr = [
  "10.25.2.16/28",
  "10.25.2.32/28",
"10.25.2.48/28"]
private_subnets_cidr = [
  "10.25.2.64/27",
  "10.25.2.96/27",
"10.25.2.128/27"]
bastion_cidr = "10.25.2.0/28"
tools_bucket_name = "tools.webapp.test."
