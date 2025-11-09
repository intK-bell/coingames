output "table_name" {
  description = "Name of the DynamoDB table."
  value       = aws_dynamodb_table.this.name
}

output "table_arn" {
  description = "ARN of the DynamoDB table."
  value       = aws_dynamodb_table.this.arn
}

output "stream_arn" {
  description = "Stream ARN if enabled."
  value       = aws_dynamodb_table.this.stream_arn
}
