variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"  # Can be overridden via tfvars
}

variable "environment" {
  description = "Environment name (e.g. dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "real-estate-app"
}

# Cognito Configuration
variable "use_ses_for_cognito" {
  description = "Whether to use Amazon SES for Cognito emails"
  type        = bool
  default     = false
}

variable "ses_email_arn" {
  description = "ARN of the SES email identity to use for Cognito emails"
  type        = string
  default     = ""
}

variable "cognito_callback_urls" {
  description = "List of allowed callback URLs for the Cognito app client"
  type        = list(string)
  default     = ["http://localhost:3000/api/auth/callback/cognito"]
}

variable "cognito_logout_urls" {
  description = "List of allowed logout URLs for the Cognito app client"
  type        = list(string)
  default     = ["http://localhost:3000"]
}

# Google IdP Configuration
variable "enable_google_idp" {
  description = "Whether to enable Google as an identity provider"
  type        = bool
  default     = false
}

variable "google_client_id" {
  description = "Google OAuth client ID"
  type        = string
  default     = ""
}

variable "google_client_secret" {
  description = "Google OAuth client secret"
  type        = string
  default     = ""
  sensitive   = true
}

# Facebook IdP Configuration
variable "enable_facebook_idp" {
  description = "Whether to enable Facebook as an identity provider"
  type        = bool
  default     = false
}

variable "facebook_client_id" {
  description = "Facebook OAuth client ID"
  type        = string
  default     = ""
}

variable "facebook_client_secret" {
  description = "Facebook OAuth client secret"
  type        = string
  default     = ""
  sensitive   = true
}

# Amazon IdP Configuration
variable "enable_amazon_idp" {
  description = "Whether to enable Login with Amazon as an identity provider"
  type        = bool
  default     = false
}

variable "amazon_client_id" {
  description = "Amazon OAuth client ID"
  type        = string
  default     = ""
}

variable "amazon_client_secret" {
  description = "Amazon OAuth client secret"
  type        = string
  default     = ""
  sensitive   = true
}

# Apple IdP Configuration
variable "enable_apple_idp" {
  description = "Whether to enable Sign in with Apple as an identity provider"
  type        = bool
  default     = false
}

variable "apple_client_id" {
  description = "Apple OAuth client ID (Services ID)"
  type        = string
  default     = ""
}

variable "apple_team_id" {
  description = "Apple team ID"
  type        = string
  default     = ""
}

variable "apple_key_id" {
  description = "Apple key ID"
  type        = string
  default     = ""
}

variable "apple_private_key" {
  description = "Apple private key for Sign in with Apple"
  type        = string
  default     = ""
  sensitive   = true
}