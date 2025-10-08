terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_user" "jenkins_user" {
  name = "yaww-user"
}

resource "aws_s3_bucket" "jenkins_bucket" {
  bucket = "jenkins-bucket-unique-name-12345"
  tags = {
    Name        = "JenkinsBucket"
    Environment = "Dev"
  }

}