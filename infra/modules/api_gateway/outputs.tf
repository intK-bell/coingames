output "api_id" {
  description = "ID of the HTTP API."
  value       = try(aws_apigatewayv2_api.this[0].id, null)
}

output "api_endpoint" {
  description = "Invoke URL of the stage."
  value       = try(aws_apigatewayv2_stage.this[0].execution_arn, null)
}

output "invoke_url" {
  description = "Invoke URL."
  value       = try(aws_apigatewayv2_stage.this[0].invoke_url, null)
}
