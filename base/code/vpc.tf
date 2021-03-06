locals {
  route_subnet_public        = concat(aws_subnet.subnet_public[*].id /*, [aws_subnet.subnet_bastion.id]*/)
  route_subnet_private_stack = concat(aws_subnet.subnet_private[*].id, [aws_subnet.subnet_elk.id])
}

#
# VPC
#
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.region_name}-${var.env_designator}-vpc1",
    Project     = var.project_name,
    Environment = var.env_designator
  }
}

# Public subnet
resource "aws_subnet" "subnet_public" {
  count = length(var.public_subnets_cidr)

  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.public_subnets_cidr[count.index]
  availability_zone = local.availability_zones[count.index]

  tags = {
    Name        = "${var.region_name}-${local.zones[count.index]}-${var.env_designator}-stack-subnet-pub",
    Project     = var.project_name,
    Environment = var.env_designator
  }
}

# Private subnet stack
resource "aws_subnet" "subnet_private" {
  count = length(var.private_subnets_cidr)

  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnets_cidr[count.index]
  availability_zone = local.availability_zones[count.index]

  tags = {
    Name        = "${var.region_name}-${local.zones[count.index]}-${var.env_designator}-stack-subnet-pri",
    Project     = var.project_name,
    Environment = var.env_designator
  }
}

# Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name        = "${var.region_name}-${var.env_designator}-stack-igw",
    Project     = var.project_name,
    Environment = var.env_designator
  }
}

# Router
# Public route tables
resource "aws_route_table" "subnet_public" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name        = "${var.region_name}-${var.env_designator}-rt",
    Project     = var.project_name,
    Environment = var.env_designator
  }
}

resource "aws_route_table" "subnet_private" {
  count  = length(var.private_subnets_cidr)
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name        = "${var.region_name}-${local.zones[count.index]}-${var.env_designator}-rt-nat",
    Project     = var.project_name,
    Environment = var.env_designator
  }
}


# Route table association
# Public subnets to the public router.
resource "aws_route_table_association" "subnet_public" {
  count          = length(local.route_subnet_public)
  subnet_id      = local.route_subnet_public[count.index]
  route_table_id = aws_route_table.subnet_public.id
}

# Private subnets to the private router.
resource "aws_route_table_association" "subnet_private" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = aws_subnet.subnet_private[count.index].id
  route_table_id = aws_route_table.subnet_private[count.index].id
}

# Traffic routing
# Public subnets
resource "aws_route" "subnet_public" {
  route_table_id         = aws_route_table.subnet_public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}


# Internet/NAT configurations, pretty standard stuff with
# A fixed EIP for the NAT is good. We only create in one Subnet
# Let
resource "aws_eip" "eip_nat_gw" {
  count = length(local.route_subnet_public)
  vpc   = true

  lifecycle {
    prevent_destroy = false
  }

  tags = {
    Name        = "${var.region_name}-${local.zones[count.index]}-${var.env_designator}-eip"
    Project     = var.project_name,
    Environment = var.env_designator
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = length(var.public_subnets_cidr)
  allocation_id = aws_eip.eip_nat_gw[count.index].id
  subnet_id     = aws_subnet.subnet_public[count.index].id
  depends_on = [
    aws_internet_gateway.internet_gateway,
  ]

  tags = {
    Name        = "${var.region_name}-${local.zones[count.index]}-${var.env_designator}-natgw"
    Project     = var.project_name,
    Environment = var.env_designator
  }
}

# Private subnets route internet traffic to the NAT
resource "aws_route" "subnet_private" {
  count                  = length(var.private_subnets_cidr)
  route_table_id         = aws_route_table.subnet_private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway[count.index].id
}
