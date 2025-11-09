variable "enabled" {
  description = "Whether to create Amplify Hosting resources."
  type        = bool
  default     = false
}

variable "app_name" {
  description = "Amplify app name."
  type        = string
}

variable "repository" {
  description = "Git repository URL."
  type        = string
  default     = ""
}

variable "access_token" {
  description = "OAuth token for repository access."
  type        = string
  default     = ""
}

variable "platform" {
  description = "Amplify platform (WEB | WEB_COMPUTE)."
  type        = string
  default     = "WEB"
}

variable "build_spec" {
  description = "Custom build specification."
  type        = string
  default     = ""
}

variable "environment_variables" {
  description = "Environment variables for Amplify app."
  type        = map(string)
  default     = {}
}

variable "branch_name" {
  description = "Branch name to deploy."
  type        = string
  default     = "main"
}

variable "service_role_arn" {
  description = "IAM service role ARN for Amplify."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply."
  type        = map(string)
  default     = {}
}
