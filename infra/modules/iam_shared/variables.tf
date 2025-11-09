variable "project_prefix" {
  description = "Prefix used for IAM role names."
  type        = string
}

variable "lambda_managed_policy_arns" {
  description = "List of managed policy ARNs to attach to the Lambda execution role."
  type        = list(string)
  default     = []
}

variable "amplify_managed_policy_arns" {
  description = "List of managed policy ARNs to attach to the Amplify service role."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to IAM resources."
  type        = map(string)
  default     = {}
}
