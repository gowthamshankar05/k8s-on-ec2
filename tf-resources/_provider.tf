provider "aws" {
  region = var.region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.26.0"
    }
  }
  backend "s3" {
    bucket         = "coimbatore-tf-state"
    key            = "terraform.tfstate"
    encrypt        = true
    dynamodb_table = "coimbatore-tf-state-dynamo-db"
    region         = "ap-south-1"
  }
}
