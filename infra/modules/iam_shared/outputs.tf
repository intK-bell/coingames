output "lambda_role_arn" {
  description = "IAM role ARN for Lambda functions."
  value       = aws_iam_role.lambda_execution.arn
}

output "amplify_role_arn" {
  description = "IAM role ARN for Amplify."
  value       = aws_iam_role.amplify_service.arn
}
