# ALB target groups
# webapp target group
resource "aws_lb_target_group" "webapp" {
  name     = "ec1-${var.env_designator}-${var.project_name}-webapp-targetgp"
  port     = 7078
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.base_resources.outputs.main_vpc_id
}

resource "aws_lb_target_group_attachment" "webapp" {
  target_group_arn = aws_lb_target_group.webapp.arn
  target_id        = aws_instance.webapp.id
  port             = 7078
}

# ALB Rules
data "aws_lb_listener" "alb" {
  arn = data.terraform_remote_state.alb_resources.outputs.alb_listener_arn
}

resource "aws_lb_listener_rule" "webapp" {
  listener_arn = data.aws_lb_listener.alb.arn
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp.arn
  }

  condition {
    host_header {
      values = [var.webapp_domain]
    }
  }
}