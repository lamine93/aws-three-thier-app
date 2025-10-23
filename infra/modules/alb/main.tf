resource "random_string" "tg" { 
  length = 5 
  special = false 
}

#######################
# ALB + TG + Listener
#######################
resource "aws_lb" "app_alb" {
  name               = "${var.project}-alb"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [var.alb_sg_id]
  subnets            = var.subnet_ids
  tags               = var.tags
}

resource "aws_lb_target_group" "app_tg" {
  name_prefix   = "tg"
  port          = var.app_port
  protocol      = "HTTP"
  target_type   = "ip"
  vpc_id        = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  depends_on = [aws_lb.app_alb]
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
