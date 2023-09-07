terraform {
  /* required_version = ">= 0.14.0" */
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "1.50.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

provider "aws" {
  region = "ap-south-1"  # Update with your desired region
}
