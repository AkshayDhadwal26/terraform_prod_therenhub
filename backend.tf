terraform {
  backend "s3" {
    bucket         = "ren-ath-configurations"
    key            = "terraform/prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    #dynamodb_table = "terraform-lock-table"
  }
}

