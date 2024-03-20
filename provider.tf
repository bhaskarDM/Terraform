terraform {
  required_providers {
    aws={
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = "eu-north-1"
}

provider "null" {
  
}
# resource "aws_s3_bucket" "terraforms3" {
#     bucket = "terraformsss"
#     force_destroy = true
#     tags={
#          Name = "mybhaskarbu"
#          environment = "Dev"
#     }  
  
# }