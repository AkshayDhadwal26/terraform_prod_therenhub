#creating security group for load balancer
resource "aws_security_group" "alb_sg" {
  name        = "alb-prod-group"
  description = "Security group for ALB"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

# Load Balancer
resource "aws_lb" "prod_lb" {
  name               = "prod-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = ["subnet-03e167944e31d065c", "subnet-03b8316f9222e2095"]

  enable_deletion_protection = false

  depends_on = [aws_acm_certificate_validation.prod]
}

# Route53 Record
resource "aws_route53_record" "prod_dns" {
  zone_id = "Z04011483MWZ7MQNJAR3"
  name    = "hostoo.online"  # Change this to your desired domain name
  type    = "A"
  alias {
    name                   = aws_lb.prod_lb.dns_name
    zone_id                = aws_lb.prod_lb.zone_id
    evaluate_target_health = true
  }
}

# Target Group
resource "aws_lb_target_group" "app_tg" {
  name     = "prod-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-01c7dd971769b69f4"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-299"
  }
}

# Listener
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.prod_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.prod.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.prod_lb.arn
  port              = "80"
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

# Attach the ASG to the target group
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.prod.name
  lb_target_group_arn   = aws_lb_target_group.app_tg.arn
}

