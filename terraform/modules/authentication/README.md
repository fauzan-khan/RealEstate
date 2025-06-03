# Authentication Module

This Terraform module sets up Amazon Cognito authentication for the Real Estate Web Application, including social identity providers (Google, Facebook, Amazon, and Apple).

## Features

- Amazon Cognito User Pool with email authentication
- Support for multiple social identity providers:
  - Google
  - Facebook
  - Login with Amazon
  - Sign in with Apple
- Cognito Identity Pool for AWS credentials federation
- IAM roles for authenticated users
- Customizable email configuration with optional Amazon SES integration
- Hosted UI with customizable callback URLs

## Usage

```hcl
module "authentication" {
  source = "./modules/authentication"

  project_name = "real-estate-app"
  environment  = "dev"
  aws_region   = "us-west-2"

  # Cognito configuration
  use_ses_for_cognito    = false
  ses_email_arn          = ""
  cognito_callback_urls  = ["http://localhost:3000/api/auth/callback/cognito"]
  cognito_logout_urls    = ["http://localhost:3000"]

  # Social Identity Providers
  enable_google_idp     = true
  google_client_id      = "your-google-client-id"
  google_client_secret  = "your-google-client-secret"

  enable_facebook_idp    = true
  facebook_client_id     = "your-facebook-client-id"
  facebook_client_secret = "your-facebook-client-secret"

  enable_amazon_idp     = true
  amazon_client_id      = "your-amazon-client-id"
  amazon_client_secret  = "your-amazon-client-secret"

  enable_apple_idp      = true
  apple_client_id       = "your-apple-client-id"
  apple_team_id         = "your-apple-team-id"
  apple_key_id          = "your-apple-key-id"
  apple_private_key     = "your-apple-private-key"

  tags = {
    Environment = "dev"
    Project     = "real-estate-app"
  }
}
```

## Requirements

- Terraform >= 1.0.0
- AWS provider ~> 5.0

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_name | Name of the project | string | - | yes |
| environment | Environment name (e.g., dev, staging, prod) | string | - | yes |
| aws_region | AWS region | string | - | yes |
| use_ses_for_cognito | Whether to use Amazon SES for Cognito emails | bool | false | no |
| ses_email_arn | ARN of the SES email identity | string | "" | no |
| cognito_callback_urls | List of allowed callback URLs | list(string) | - | yes |
| cognito_logout_urls | List of allowed logout URLs | list(string) | - | yes |
| enable_google_idp | Enable Google as identity provider | bool | false | no |
| google_client_id | Google OAuth client ID | string | "" | no |
| google_client_secret | Google OAuth client secret | string | "" | no |
| enable_facebook_idp | Enable Facebook as identity provider | bool | false | no |
| facebook_client_id | Facebook OAuth client ID | string | "" | no |
| facebook_client_secret | Facebook OAuth client secret | string | "" | no |
| enable_amazon_idp | Enable Login with Amazon as identity provider | bool | false | no |
| amazon_client_id | Amazon OAuth client ID | string | "" | no |
| amazon_client_secret | Amazon OAuth client secret | string | "" | no |
| enable_apple_idp | Enable Sign in with Apple as identity provider | bool | false | no |
| apple_client_id | Apple OAuth client ID | string | "" | no |
| apple_team_id | Apple team ID | string | "" | no |
| apple_key_id | Apple key ID | string | "" | no |
| apple_private_key | Apple private key | string | "" | no |
| tags | Tags to apply to resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| user_pool_id | ID of the Cognito User Pool |
| user_pool_arn | ARN of the Cognito User Pool |
| user_pool_endpoint | Endpoint of the Cognito User Pool |
| app_client_id | ID of the Cognito User Pool Client |
| app_client_secret | Secret of the Cognito User Pool Client |
| identity_pool_id | ID of the Cognito Identity Pool |
| identity_pool_arn | ARN of the Cognito Identity Pool |
| hosted_ui_domain | Domain of the Cognito Hosted UI |
| authenticated_role_arn | ARN of the IAM role for authenticated users |

## Social Identity Provider Setup

### Google

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Navigate to "APIs & Services" > "Credentials"
4. Click "Create Credentials" > "OAuth client ID"
5. Configure the OAuth consent screen
6. Add authorized JavaScript origins and redirect URIs
7. Note the Client ID and Client Secret

### Facebook

1. Go to [Facebook Developers](https://developers.facebook.com/)
2. Create a new app or select an existing one
3. Add the Facebook Login product
4. Configure OAuth settings
5. Note the App ID and App Secret

### Amazon

1. Go to the [Amazon Developer Console](https://developer.amazon.com/)
2. Register a new app or select an existing one
3. Configure Security Profile settings
4. Add allowed origins and return URLs
5. Note the Client ID and Client Secret

### Apple

1. Go to the [Apple Developer Portal](https://developer.apple.com/)
2. Create a Services ID and enable Sign in with Apple
3. Configure domains and return URLs
4. Create a private key
5. Note the Client ID, Team ID, Key ID, and private key

## Notes

- Make sure to configure the social identity providers before enabling them in the module
- The Cognito domain name must be globally unique
- Store sensitive values like client secrets in a secure way (e.g., AWS Secrets Manager)
- Consider using Amazon SES for production environments to customize email templates