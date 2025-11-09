variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
}

variable "project" {
  description = "Project prefix for resource naming."
  type        = string
}

variable "environment" {
  description = "Deployment environment identifier (e.g., dev, stg, prod)."
  type        = string
}

variable "default_tags" {
  description = "Additional default tags applied to every resource."
  type        = map(string)
  default     = {}
}

variable "enable_lambda" {
  description = "Enable Lambda deployment."
  type        = bool
  default     = false
}

variable "lambda_package_path" {
  description = "Path to the zipped Nest.js bundle for Lambda."
  type        = string
  default     = ""
}

variable "lambda_handler" {
  description = "Lambda handler entrypoint."
  type        = string
  default     = "dist/main.handler"
}

variable "lambda_runtime" {
  description = "Lambda runtime version."
  type        = string
  default     = "nodejs18.x"
}

variable "lambda_memory_size" {
  description = "Lambda memory in MB."
  type        = number
  default     = 512
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds."
  type        = number
  default     = 10
}

variable "lambda_environment" {
  description = "Environment variables for the Lambda function."
  type        = map(string)
  default     = {}
}

variable "enable_api_gateway" {
  description = "Enable API Gateway deployment."
  type        = bool
  default     = false
}

variable "api_gateway_stage_name" {
  description = "Stage name for API Gateway."
  type        = string
  default     = "$default"
}

variable "api_gateway_allowed_origins" {
  description = "CORS allowed origins for API Gateway."
  type        = list(string)
  default     = ["*"]
}

variable "enable_amplify_hosting" {
  description = "Enable Amplify Hosting."
  type        = bool
  default     = false
}

variable "amplify_repository" {
  description = "Git repository for Amplify app (optional)."
  type        = string
  default     = ""
}

variable "amplify_access_token" {
  description = "OAuth token for Amplify repository access."
  type        = string
  default     = ""
  sensitive   = true
}

variable "amplify_branch" {
  description = "Branch to deploy in Amplify."
  type        = string
  default     = "main"
}
