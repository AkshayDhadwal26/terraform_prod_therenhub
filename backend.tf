terraform {
  backend "s3" {
    bucket         = "nginx-default"
    key            = "terraform/prod/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-table"
  }
}

