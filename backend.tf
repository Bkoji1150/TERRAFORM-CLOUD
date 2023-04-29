
terraform {
  # required_version = ">=1.3.0"

  backend "s3" {
    bucket         = "prod-nfor" # s3 bucket 
    key            = "path/env/hqr-auto-scaling-terraform"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt        = "true"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
