# Define provider
provider "aws" {
  region = "ap-south-1"  # Specify your desired AWS region
}

# Create a launch template
resource "aws_launch_template" "prod_launch_template" {
  name_prefix   = "prod-launch-template-"
  description   = "Prod Launch Template"
  
  instance_type          = "t2.micro"
  image_id               = "ami-0f58b397bc5c1f2e8"  # Specify your desired AMI ID
  key_name               = "prod-key"  # Specify the name of your EC2 key pair
  
  security_group_names = [aws_security_group.prod.id] 
  
  iam_instance_profile {
    name = aws_iam_role.admin_role.name
  } 
  
  user_data = base64encode(<<-EOF
    #!/bin/bash
    #installing docker
    apt-get update
    apt install docker.io -y
    sudo aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 931623615406.dkr.ecr.ap-south-1.amazonaws.com
    sudo docker pull 931623615406.dkr.ecr.ap-south-1.amazonaws.com/prod:frontend
    sudo docker pull 931623615406.dkr.ecr.ap-south-1.amazonaws.com/prod:backend

    # Create Docker Compose file
    wget https://nginx-default.s3.ap-south-1.amazonaws.com/docker-compose.yml -O /root/docker-compose.yaml

    # Start Docker Compose services
    docker compose -f /root/docker-compose.yaml up -d 

    #installing nginx and placing own configuration
    apt install nginx -y
    wget https://nginx-default.s3.ap-south-1.amazonaws.com/default.conf -O /etc/nginx/sites-available/default
    systemctl restart nginx
   

    #Creating script for regular check of updated docker image
    wget https://nginx-default.s3.ap-south-1.amazonaws.com/script.bash -O /root/script.bash
    # Make the script executable
    sudo chmod +x /root/script.bash

    # Add cron job to run the script every 10 minutes
    echo "*/10 * * * * root /root/script.bash" | sudo tee -a /etc/crontab
  EOF
)

  tags = {
    Name = "ProdLaunchTemplate"
  }
}

