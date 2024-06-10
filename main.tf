# Define provider
provider "aws" {
  region = var.region  # Specify your desired AWS region
}

# Create a launch template
resource "aws_launch_template" "prod_launch_template" {
  name_prefix   = "prod-launch-template-"
  description   = "Prod Launch Template"
  
  instance_type          = var.instance_type
  image_id               = var.image_id  # Specify your desired AMI ID
  key_name               = "prod-key"  # Specify the name of your EC2 key pair
  
  #security_groups	 = [aws_security_group.prod.id] 
  
  iam_instance_profile {
    name = aws_iam_instance_profile.prod_instance_profile.name
  }
  network_interfaces {
    associate_public_ip_address = true
    subnet_id                   = element(var.vpc_zone_identifier, 0)
    security_groups             = [aws_security_group.prod.id]
  } 
  
  user_data = base64encode(<<-EOF
    #!/bin/bash
    #installing docker
    apt-get update

    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl -y
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    snap install aws-cli --classic
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
    systemctl daemon-reload
    systemctl restart nginx
   

    #Creating script for regular check of updated docker image
    #wget https://nginx-default.s3.ap-south-1.amazonaws.com/script.bash -O /root/script.bash
    # Make the script executable
    #sudo chmod +x /root/script.bash

    # Add cron job to run the script every 10 minutes
    #echo "*/5 * * * * root /root/script.bash" | sudo tee -a /etc/crontab
  EOF
)

  tags = {
    Name = "ProdLaunchTemplate"
  }
}
