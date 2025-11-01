resource "aws_lb" "todo_app_alb" {
  name               = "todo-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.todo_alb_sg.id]
  subnets            = aws_subnet.todo_public_subnet[*].id

  tags = {
    Name = "todo-app-alb"
  }
}

resource "aws_lb_target_group" "todo_ecs_tg" {
  name        = "todo-ecs-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.todo_vpc.id
  target_type = "ip"

  health_check {
    path                = "/"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "todo-ecs-tg"
  }
}

# resource "aws_lb_listener" "http" {
#   load_balancer_arn = aws_lb.todo_app_alb.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.todo_ecs_tg.arn
#   }
# }

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.todo_app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# ---------------- HTTPS Listener -----------------
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.todo_app_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.todo_ecs_tg.arn
  }

  depends_on = [aws_lb.todo_app_alb]
}
