output "app_id" {
  description = "Amplify App ID."
  value       = try(aws_amplify_app.this[0].id, null)
}

output "default_domain" {
  description = "Default domain of the Amplify app."
  value       = try(aws_amplify_app.this[0].default_domain, null)
}

output "branch_name" {
  description = "Deployed branch name."
  value       = try(aws_amplify_branch.this[0].branch_name, null)
}
