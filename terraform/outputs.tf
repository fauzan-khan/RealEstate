# Cognito Outputs
output "cognito_user_pool_id" {
  description = "ID of the Cognito User Pool"
  value       = module.authentication.user_pool_id
}

output "cognito_user_pool_arn" {
  description = "ARN of the Cognito User Pool"
  value       = module.authentication.user_pool_arn
}

output "cognito_app_client_id" {
  description = "ID of the Cognito User Pool Client"
  value       = module.authentication.app_client_id
}

output "cognito_app_client_secret" {
  description = "Secret of the Cognito User Pool Client"
  value       = module.authentication.app_client_secret
  sensitive   = true
}

output "cognito_identity_pool_id" {
  description = "ID of the Cognito Identity Pool"
  value       = module.authentication.identity_pool_id
}

output "cognito_identity_pool_arn" {
  description = "ARN of the Cognito Identity Pool"
  value       = module.authentication.identity_pool_arn
}

output "cognito_hosted_ui_domain" {
  description = "Domain of the Cognito Hosted UI"
  value       = module.authentication.hosted_ui_domain
}

output "cognito_authenticated_role_arn" {
  description = "ARN of the IAM role for authenticated users"
  value       = module.authentication.authenticated_role_arn
}