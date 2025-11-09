resource "aws_lambda_function" "this" {
  count = var.enabled ? 1 : 0

  function_name    = var.function_name
  role             = var.role_arn
  handler          = var.handler
  runtime          = var.runtime
  memory_size      = var.memory_size
  timeout          = var.timeout
  filename         = var.package_path
  source_code_hash = filebase64sha256(var.package_path)

  layers = var.layers

  environment {
    variables = var.environment
  }

  dynamic "vpc_config" {
    for_each = length(var.subnet_ids) > 0 ? [1] : []
    content {
      subnet_ids         = var.subnet_ids
      security_group_ids = var.security_group_ids
    }
  }

  tags = var.tags
}
