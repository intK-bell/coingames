variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "project" {
  description = "Project name."
  type        = string
}

variable "environment" {
  description = "Environment identifier."
  type        = string
}

variable "state_bucket_name" {
  description = "S3 bucket name for Terraform remote state."
  type        = string
}

variable "state_lock_table_name" {
  description = "DynamoDB table name for Terraform state lock."
  type        = string
}

variable "default_tags" {
  description = "Additional default tags."
  type        = map(string)
  default     = {}
}
