locals {
  stage_suffix_raw = replace(var.stage_name, "$", "default")
  stage_suffix     = replace(local.stage_suffix_raw, "/", "-")
}

resource "aws_apigatewayv2_api" "this" {
  count = var.enabled ? 1 : 0

  name          = var.name
  protocol_type = "HTTP"

  cors_configuration {
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_origins = var.cors_allowed_origins
    allow_headers = ["*"]
  }

  tags = var.tags
}

resource "aws_apigatewayv2_integration" "lambda" {
  count = var.enabled ? 1 : 0

  api_id                 = aws_apigatewayv2_api.this[0].id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "default" {
  count = var.enabled ? 1 : 0

  api_id    = aws_apigatewayv2_api.this[0].id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda[0].id}"
}

resource "aws_apigatewayv2_stage" "this" {
  count = var.enabled ? 1 : 0

  api_id      = aws_apigatewayv2_api.this[0].id
  name        = var.stage_name
  auto_deploy = true

  tags = var.tags
}

resource "aws_lambda_permission" "apigw" {
  count = var.enabled ? 1 : 0

  statement_id  = "apigw-${local.stage_suffix}"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this[0].execution_arn}/*/*"
}
