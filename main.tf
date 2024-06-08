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
  
  user_data = <<-EOF
#!/bin/bash
#installing docker
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
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

sudo aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 931623615406.dkr.ecr.ap-south-1.amazonaws.com
sudo docker pull 931623615406.dkr.ecr.ap-south-1.amazonaws.com/prod:frontend
sudo docker pull 931623615406.dkr.ecr.ap-south-1.amazonaws.com/prod:backend

# Create Docker Compose file
cat <<EOL > /root/docker-compose.yaml
version: '3.8'

services:
  frontend:
    image: 931623615406.dkr.ecr.ap-south-1.amazonaws.com/prod:frontend
    container_name: frontend_container
    ports:
      - "81:80"

  backend:
    image: 931623615406.dkr.ecr.ap-south-1.amazonaws.com/prod:backend
    container_name: backend_container
    ports:
      - "3000:3000"
EOL

# Start Docker Compose services
docker compose -f /root/docker-compose.yaml up -d 


#installing nginx and placing own configuration
apt install nginx -y
wget https://nginx-default.s3.ap-south-1.amazonaws.com/default.conf -O /etc/nginx/sites-available/default
systemctl restart nginx


echo "\
#!/bin/bash

# Variables
REGION="us-west-2"  # Replace with your AWS region
REPOSITORY_NAME="your-ecr-repo-name"  # Replace with your ECR repository name
IMAGE_TAG="prod"  # The tag to check and pull

# Authenticate Docker with ECR
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query "Account" --output text).dkr.ecr.$REGION.amazonaws.com

# Pull the latest image using Docker Compose and capture the output
PULL_OUTPUT=$(docker-compose pull)

# Check if any images were updated
if echo "$PULL_OUTPUT" | grep -q "Downloaded newer image"; then
  echo "New image pulled. Restarting the services using Docker Compose."
  docker-compose up -d
else
  echo "No new images were pulled. No need to restart the services."
fi
">>/root/script.bash

# Make the script executable
sudo chmod +x /root/script.bash


# Add cron job to run the script every 10 minutes
echo "*/10 * * * * root /root/script.bash" | sudo tee -a /etc/crontab

EOF


  tags = {
    Name = "ProdLaunchTemplate"
  }
}

