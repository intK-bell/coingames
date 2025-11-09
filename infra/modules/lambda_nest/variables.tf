variable "enabled" {
  description = "Whether to create the Lambda function."
  type        = bool
  default     = false
}

variable "function_name" {
  description = "Lambda function name."
  type        = string
}

variable "package_path" {
  description = "Path to the zipped Nest.js bundle."
  type        = string
}

variable "handler" {
  description = "Lambda handler (e.g., dist/main.handler)."
  type        = string
}

variable "runtime" {
  description = "Lambda runtime."
  type        = string
  default     = "nodejs18.x"
}

variable "role_arn" {
  description = "IAM role ARN for Lambda execution."
  type        = string
}

variable "memory_size" {
  description = "Lambda memory size in MB."
  type        = number
  default     = 512
}

variable "timeout" {
  description = "Lambda timeout in seconds."
  type        = number
  default     = 10
}

variable "environment" {
  description = "Environment variables for the Lambda function."
  type        = map(string)
  default     = {}
}

variable "layers" {
  description = "Lambda layer ARNs."
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "VPC subnet IDs."
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "VPC security group IDs."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
