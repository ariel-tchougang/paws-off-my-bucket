variable "bucket_name" {
  description = "Name of the existing S3 bucket"
  type        = string
}

variable "environment" {
  description = "Environment label for tagging"
  type        = string
  default     = "demo"
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-1"
}