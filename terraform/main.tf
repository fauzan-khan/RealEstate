# Main Terraform configuration file



# Authentication Module
module "authentication" {
  source = "./modules/authentication"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  # Cognito configuration
  use_ses_for_cognito = var.use_ses_for_cognito
  ses_email_arn       = var.ses_email_arn
  cognito_callback_urls = var.cognito_callback_urls
  cognito_logout_urls   = var.cognito_logout_urls

  # Social Identity Providers
  enable_google_idp     = var.enable_google_idp
  google_client_id      = var.google_client_id
  google_client_secret  = var.google_client_secret

  enable_facebook_idp    = var.enable_facebook_idp
  facebook_client_id     = var.facebook_client_id
  facebook_client_secret = var.facebook_client_secret

  enable_amazon_idp     = var.enable_amazon_idp
  amazon_client_id      = var.amazon_client_id
  amazon_client_secret  = var.amazon_client_secret

  enable_apple_idp      = var.enable_apple_idp
  apple_client_id       = var.apple_client_id
  apple_team_id         = var.apple_team_id
  apple_key_id          = var.apple_key_id
  apple_private_key     = var.apple_private_key

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}