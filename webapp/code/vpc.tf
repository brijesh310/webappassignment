resource "aws_security_group" "webapp" {
  name        = "${var.region_name}-${var.env_designator}-webapp-sg"
  description = "SG to enable communication to webapp"
  vpc_id      = data.terraform_remote_state.base_resources.outputs.main_vpc_id

  ingress {
    description = "SSH to webapp"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.webapp_sg_ssh
  }

  ingress {
    description     = "All ALB connects to webapp"
    from_port       = 7078
    to_port         = 7078
    protocol        = "tcp"
    security_groups = [data.terraform_remote_state.alb_resources.outputs.alb_sg]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.mandatory_tags,
    map("Name", "${var.region_name}-${var.env_designator}-webapp-sg")
  )
}

# ALB
# Modify ALB security groups
data "aws_security_group" "alb" {
  id = data.terraform_remote_state.alb_resources.outputs.alb_sg
}

# OUTBOUND
resource "aws_security_group_rule" "alb_to_sg" {
  type                     = "egress"
  from_port                = 7078
  to_port                  = 7078
  protocol                 = "tcp"
  security_group_id        = data.aws_security_group.alb.id
  source_security_group_id = aws_security_group.webapp.id
  description              = "Allow ALB connects to webapp"
}