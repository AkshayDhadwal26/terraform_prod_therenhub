variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1" 
}

variable "vpc_id" {
  description = "The VPC ID where resources will be deployed"
  type        = string
  default     = "vpc-0a2e663921722605a" # Optional: you can set a default value
}

variable "all_sub_domain_name" {
  description = "The domain name for the ACM certificate"
  type        = string
  default     = "*.therenhub.com"
}


variable "vpc_zone_identifier" {
  description = "List of subnet IDs for the VPC"
  type        = list(string)
  default     = ["subnet-0aeb2d656a8846cdd", "subnet-0682ee3e22607de63"]
}

variable "zone_id" {
  description = "Zone id for Domain name"
  type	      = string
  default     = "Z06818781WDBEQQCYGZAV"
}

variable "image_id" {
  description = "Image Id for instances"
  type        = string
  default     = "ami-053b0d53c279acc90" #ubuntu in region us-east-1
}

variable "instance_type" {
  description = "Defines the size of the instance to be created"
  type        = string
  default     = "t2.medium"
}

variable "acm_certificate" {
  description = "Certificate for Load Balancer"
  type        = string
  default     = "arn:aws:acm:us-east-1:438786549001:certificate/6a383fcf-7091-479c-b2f4-6ba38943762e"
}
