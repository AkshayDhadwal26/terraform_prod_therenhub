resource "aws_security_group" "prod" {
  name        = "prod-security-group"
  description = "prod security group"

  # Define ingress rules
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from any IP address
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP from any IP address
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP from any IP address
  }

  ingress {
    from_port   = 300
    to_port     = 300
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP from any IP address
  }

  # Define egress rules (allow all outbound traffic)
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"  # Allow all protocols
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


