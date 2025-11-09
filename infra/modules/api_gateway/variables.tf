variable "enabled" {
  description = "Whether to create the API Gateway resources."
  type        = bool
  default     = false
}

variable "name" {
  description = "Name of the HTTP API."
  type        = string
}

variable "lambda_invoke_arn" {
  description = "Invoke ARN of the Lambda integration."
  type        = string
}

variable "lambda_function_arn" {
  description = "ARN of the Lambda function used for permissions."
  type        = string
}

variable "stage_name" {
  description = "Deployment stage name."
  type        = string
  default     = "$default"
}

variable "cors_allowed_origins" {
  description = "CORS allowed origins."
  type        = list(string)
  default     = ["*"]
}

variable "tags" {
  description = "Tags for API resources."
  type        = map(string)
  default     = {}
}
