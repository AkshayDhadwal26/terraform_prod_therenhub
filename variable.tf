variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "ap-south-1" 
}

variable "vpc_id" {
  description = "The VPC ID where resources will be deployed"
  type        = string
  default     = "vpc-01c7dd971769b69f4" # Optional: you can set a default value
}

variable "domain_name" {
  description = "The domain name for the ACM certificate"
  type        = string
  default     = "*.hostoo.online"
}

variable "backend_domain_name" {
  description = "The domain name for the ACM certificate"
  type        = string
  default     = "api.hostoo.online"
}


variable "vpc_zone_identifier" {
  description = "List of subnet IDs for the VPC"
  type        = list(string)
  default     = ["subnet-03e167944e31d065c", "subnet-03b8316f9222e2095"]
}

variable "zone_id" {
  description = "Zone id for Domain name"
  type	      = string
  default     = "Z04011483MWZ7MQNJAR3"
}

variable "image_id" {
  description = "Image Id for instances"
  type        = string
  default     = "ami-0f58b397bc5c1f2e8" #ubuntu in region ap-south-1
}

variable "instance_type" {
  description = "Defines the size of the instance to be created"
  type        = string
  default     = "t2.micro"
}

#variable "subnet_id" {
#  description = "Subnet for network interfaces"
#  type        = string
#  default     = "subnet-03e167944e31d065c"
#}
