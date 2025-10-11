
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "terraform-state-jenkins-12345"
    key            = "state/terraform.tfstate"
    region         = "eu-west-1"
  }
}

provider "aws" {
  region = "eu-west-1"
}

# Existing IAM user
resource "aws_iam_user" "jenkins_user" {
  name = "PaaYaw"
}

# Existing S3 bucket for Jenkins
resource "aws_s3_bucket" "jenkins_bucket" {
  bucket = "jenkins-bucket-unique-name-12345"
  tags = {
    Name        = "JenkinsBucket"
    Environment = "test"
  }
}
