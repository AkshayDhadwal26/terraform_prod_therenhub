#creating security group for load balancer
resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"
  description = "Security group for ALB"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

#creating frontend load balancer for prod
resource "aws_lb" "frontend" {
  name               = "frontend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = ["subnet-03e167944e31d065c", "subnet-03b8316f9222e2095"]

  tags = {
    Name = "frontend-alb"
  }
}

#creating target group for frontend load balancer
resource "aws_lb_target_group" "prod-frontend" {
  name     = "prod-frontend-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-01c7dd971769b69f4"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = 80
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

#adding listner to frontend load balancer
resource "aws_lb_listener" "prod-frontend" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod-frontend.arn
  }
}

#attaching frontend target group to frontend load balancer
resource "aws_autoscaling_attachment" "prod-frontend" {
  lb_target_group_arn  = aws_lb_target_group.prod-frontend.arn
  autoscaling_group_name = aws_autoscaling_group.prod.name
}


# Creating backend load balancer
resource "aws_lb" "backend" {
  name               = "backend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = ["subnet-03e167944e31d065c", "subnet-03b8316f9222e2095"]

  tags = {
    Name = "backend-alb"
  }
}

# Creating target group for backend load balancer
resource "aws_lb_target_group" "backend" {
  name     = "backend-target-group"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = "vpc-01c7dd971769b69f4"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = 3000
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# Adding listener to backend load balancer
resource "aws_lb_listener" "backend" {
  load_balancer_arn = aws_lb.backend.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}
