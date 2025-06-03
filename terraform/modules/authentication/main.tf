locals {
  domain_prefix = "${var.project_name}-${var.environment}"
}

variable "project_name" {
  
}
# Cognito User Pool
resource "aws_cognito_user_pool" "main" {
  name = "${var.project_name}-${var.environment}"

  # Username configuration
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  # Password policy
  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  # MFA configuration
  mfa_configuration = "OPTIONAL"
  software_token_mfa_configuration {
    enabled = true
  }

  # Email configuration
  dynamic "email_configuration" {
    for_each = var.use_ses_for_cognito ? [1] : []
    content {
      source_arn            = var.ses_email_arn
      email_sending_account = "DEVELOPER"
    }
  }

  # Schema attributes
  schema {
    name                = "role"
    attribute_data_type = "String"
    mutable            = true
    required           = false
    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  schema {
    name                = "phone_verified"
    attribute_data_type = "Boolean"
    mutable            = true
    required           = false
  }

  # Account recovery
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  # Admin create user config
  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  # Device configuration
  device_configuration {
    challenge_required_on_new_device      = false
    device_only_remembered_on_user_prompt = true
  }

  # User pool add-ons
  user_pool_add_ons {
    advanced_security_mode = "AUDIT"
  }

  tags = var.tags
}

# Cognito User Pool Client
resource "aws_cognito_user_pool_client" "main" {
  name                                 = "${var.project_name}-${var.environment}-client"
  user_pool_id                        = aws_cognito_user_pool.main.id
  generate_secret                     = true
  allowed_oauth_flows                 = ["code"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes                = ["email", "openid", "profile"]
  callback_urls                       = var.cognito_callback_urls
  logout_urls                         = var.cognito_logout_urls
  supported_identity_providers        = concat(
    ["COGNITO"],
    var.enable_google_idp ? ["Google"] : [],
    var.enable_facebook_idp ? ["Facebook"] : [],
    var.enable_amazon_idp ? ["LoginWithAmazon"] : [],
    var.enable_apple_idp ? ["SignInWithApple"] : []
  )

  # Token configuration
  token_validity_units {
    access_token  = "hours"
    id_token     = "hours"
    refresh_token = "days"
  }

  access_token_validity  = 1
  id_token_validity     = 1
  refresh_token_validity = 30

  # OAuth configuration
  explicit_auth_flows = [
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_USER_PASSWORD_AUTH"
  ]

  prevent_user_existence_errors = "ENABLED"
}

# Cognito User Pool Domain
resource "aws_cognito_user_pool_domain" "main" {
  domain       = local.domain_prefix
  user_pool_id = aws_cognito_user_pool.main.id
}

# Google Identity Provider (if enabled)
resource "aws_cognito_identity_provider" "google" {
  count         = var.enable_google_idp ? 1 : 0
  user_pool_id  = aws_cognito_user_pool.main.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    client_id        = var.google_client_id
    client_secret    = var.google_client_secret
    authorize_scopes = "email profile openid"
  }

  attribute_mapping = {
    email    = "email"
    username = "sub"
    given_name = "given_name"
    family_name = "family_name"
    picture = "picture"
  }
}

# Facebook Identity Provider (if enabled)
resource "aws_cognito_identity_provider" "facebook" {
  count         = var.enable_facebook_idp ? 1 : 0
  user_pool_id  = aws_cognito_user_pool.main.id
  provider_name = "Facebook"
  provider_type = "Facebook"

  provider_details = {
    client_id        = var.facebook_client_id
    client_secret    = var.facebook_client_secret
    authorize_scopes = "email public_profile"
    api_version      = "v15.0"
  }

  attribute_mapping = {
    email    = "email"
    username = "id"
    given_name = "first_name"
    family_name = "last_name"
    picture = "picture"
  }
}

# Amazon Identity Provider (if enabled)
resource "aws_cognito_identity_provider" "amazon" {
  count         = var.enable_amazon_idp ? 1 : 0
  user_pool_id  = aws_cognito_user_pool.main.id
  provider_name = "LoginWithAmazon"
  provider_type = "LoginWithAmazon"

  provider_details = {
    client_id        = var.amazon_client_id
    client_secret    = var.amazon_client_secret
    authorize_scopes = "profile postal_code"
  }

  attribute_mapping = {
    email    = "email"
    username = "user_id"
    given_name = "name"
  }
}

# Apple Identity Provider (if enabled)
resource "aws_cognito_identity_provider" "apple" {
  count         = var.enable_apple_idp ? 1 : 0
  user_pool_id  = aws_cognito_user_pool.main.id
  provider_name = "SignInWithApple"
  provider_type = "SignInWithApple"

  provider_details = {
    client_id        = var.apple_client_id
    team_id         = var.apple_team_id
    key_id          = var.apple_key_id
    private_key     = var.apple_private_key
    authorize_scopes = "email name"
  }

  attribute_mapping = {
    email    = "email"
    username = "sub"
    given_name = "firstName"
    family_name = "lastName"
  }
}

# Cognito Identity Pool
resource "aws_cognito_identity_pool" "main" {
  identity_pool_name               = "${var.project_name}-${var.environment}"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.main.id
    provider_name          = aws_cognito_user_pool.main.endpoint
    server_side_token_check = false
  }

  dynamic "cognito_identity_providers" {
    for_each = var.enable_google_idp ? [1] : []
    content {
      client_id     = var.google_client_id
      provider_name = "cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.main.id}:Google"
    }
  }

  dynamic "cognito_identity_providers" {
    for_each = var.enable_facebook_idp ? [1] : []
    content {
      client_id     = var.facebook_client_id
      provider_name = "cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.main.id}:Facebook"
    }
  }

  dynamic "cognito_identity_providers" {
    for_each = var.enable_amazon_idp ? [1] : []
    content {
      client_id     = var.amazon_client_id
      provider_name = "cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.main.id}:LoginWithAmazon"
    }
  }

  dynamic "cognito_identity_providers" {
    for_each = var.enable_apple_idp ? [1] : []
    content {
      client_id     = var.apple_client_id
      provider_name = "cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.main.id}:SignInWithApple"
    }
  }
}

# IAM roles for Cognito Identity Pool
resource "aws_iam_role" "authenticated" {
  name = "${var.project_name}-${var.environment}-cognito-authenticated"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.main.id
          }
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "authenticated"
          }
        }
      }
    ]
  })
}

# Attach basic permissions for authenticated users
resource "aws_iam_role_policy" "authenticated" {
  name = "${var.project_name}-${var.environment}-cognito-authenticated"
  role = aws_iam_role.authenticated.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "mobileanalytics:PutEvents",
          "cognito-sync:*",
          "cognito-identity:*"
        ]
        Resource = ["*"]
      }
    ]
  })
}

# Attach roles to Identity Pool
resource "aws_cognito_identity_pool_roles_attachment" "main" {
  identity_pool_id = aws_cognito_identity_pool.main.id

  roles = {
    authenticated = aws_iam_role.authenticated.arn
  }
}