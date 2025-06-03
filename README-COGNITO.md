# Amazon Cognito Authentication Setup Guide

This guide explains how to set up and configure Amazon Cognito authentication for the Real Estate Web Application, including social identity providers (Google, Facebook, Amazon, and Apple).

## Table of Contents

1. [Terraform Configuration](#terraform-configuration)
2. [Social Identity Provider Setup](#social-identity-provider-setup)
3. [Frontend Integration](#frontend-integration)
4. [Environment Variables](#environment-variables)
5. [Testing Authentication](#testing-authentication)

## Terraform Configuration

The Terraform configuration for Amazon Cognito is defined in the `terraform/modules/authentication` directory. This module sets up:

- Amazon Cognito User Pool
- User Pool Client
- Identity Pool
- Social Identity Providers
- IAM Roles for authenticated users

### Deployment Steps

1. Update the required variables in your environment's `.tfvars` file:

```hcl
# Authentication configuration
use_ses_for_cognito = false  # Set to true if using Amazon SES for emails
ses_email_arn       = ""     # ARN of the SES email identity (if using SES)

cognito_callback_urls = [
  "http://localhost:3000/api/auth/callback/cognito"  # For local development
]
cognito_logout_urls = [
  "http://localhost:3000"  # For local development
]

# Social Identity Provider credentials
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
apple_private_key     = <<EOT
-----BEGIN PRIVATE KEY-----
YourApplePrivateKeyHere
-----END PRIVATE KEY-----
EOT
```

2. Deploy the Terraform configuration:

```bash
cd terraform/environments/dev
terraform init
terraform apply
```

3. After deployment, note the outputs for:
   - `cognito_user_pool_id`
   - `cognito_app_client_id`
   - `cognito_identity_pool_id`
   - `cognito_hosted_ui_url`

## Social Identity Provider Setup

### Google

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Navigate to "APIs & Services" > "Credentials"
4. Click "Create Credentials" > "OAuth client ID"
5. Select "Web application" as the application type
6. Add authorized JavaScript origins:
   - `https://your-cognito-domain.auth.region.amazoncognito.com`
7. Add authorized redirect URIs:
   - `https://your-cognito-domain.auth.region.amazoncognito.com/oauth2/idpresponse`
8. Click "Create" and note the Client ID and Client Secret

### Facebook

1. Go to the [Facebook Developers](https://developers.facebook.com/)
2. Create a new app or select an existing one
3. Navigate to "Settings" > "Basic"
4. Note the App ID and App Secret
5. Add the following OAuth Redirect URI:
   - `https://your-cognito-domain.auth.region.amazoncognito.com/oauth2/idpresponse`
6. Under "Products", add "Facebook Login" and configure it with the same redirect URI

### Amazon

1. Go to the [Amazon Developer Console](https://developer.amazon.com/)
2. Register a new app or select an existing one
3. Navigate to "Security Profiles" and create a new security profile
4. Under "Web Settings", add the following:
   - Allowed Origins: `https://your-cognito-domain.auth.region.amazoncognito.com`
   - Allowed Return URLs: `https://your-cognito-domain.auth.region.amazoncognito.com/oauth2/idpresponse`
5. Note the Client ID and Client Secret

### Apple

1. Go to the [Apple Developer Portal](https://developer.apple.com/)
2. Navigate to "Certificates, Identifiers & Profiles"
3. Create a new Services ID
4. Enable "Sign In with Apple" and configure the following:
   - Domains: `amazoncognito.com`
   - Return URLs: `https://your-cognito-domain.auth.region.amazoncognito.com/oauth2/idpresponse`
5. Create a new private key for Sign In with Apple
6. Note the Client ID (Services ID), Team ID, Key ID, and download the private key

## Frontend Integration

The frontend integration is handled by the following files:

- `src/lib/auth/cognito.ts`: Utilities for interacting with Amazon Cognito
- `src/lib/auth/AuthContext.tsx`: React context for authentication state management
- `src/components/auth/SignInForm.tsx`: Sign-in form component
- `src/components/auth/SignUpForm.tsx`: Sign-up form component
- `src/middleware.ts`: Authentication middleware for protected routes
- `src/app/api/auth/[...nextauth]/route.ts`: NextAuth.js configuration

### Required Dependencies

Install the following dependencies:

```bash
npm install aws-amplify next-auth @hookform/resolvers zod react-hook-form react-icons jose
```

## Environment Variables

Create a `.env.local` file based on the `.env.example` template:

```
# AWS Region
NEXT_PUBLIC_AWS_REGION=us-east-1
AWS_REGION=us-east-1

# Cognito Configuration
NEXT_PUBLIC_COGNITO_USER_POOL_ID=us-east-1_xxxxxxxx
NEXT_PUBLIC_COGNITO_CLIENT_ID=xxxxxxxxxxxxxxxxxxxxxxxxxx
COGNITO_CLIENT_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
NEXT_PUBLIC_COGNITO_DOMAIN=real-estate-dev
NEXT_PUBLIC_COGNITO_REDIRECT_SIGN_IN=http://localhost:3000/api/auth/callback/cognito
NEXT_PUBLIC_COGNITO_REDIRECT_SIGN_OUT=http://localhost:3000

# NextAuth Secret
NEXTAUTH_SECRET=your-nextauth-secret
NEXTAUTH_URL=http://localhost:3000

# Social Identity Providers
# Google
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret

# Facebook
FACEBOOK_CLIENT_ID=your-facebook-client-id
FACEBOOK_CLIENT_SECRET=your-facebook-client-secret

# Apple
APPLE_CLIENT_ID=your-apple-client-id
APPLE_CLIENT_SECRET=your-apple-client-secret
```

## Testing Authentication

1. Start your Next.js application:

```bash
npm run dev
```

2. Navigate to the sign-in page at `http://localhost:3000/signin`

3. Test the following authentication flows:
   - Email/password sign-up and sign-in
   - Social identity provider sign-in (Google, Facebook, Amazon, Apple)
   - Password reset
   - Account verification

4. Test protected routes to ensure the authentication middleware is working correctly

## Troubleshooting

### Common Issues

1. **CORS Errors**: Ensure that the allowed origins in Cognito and social identity providers match your application's domain.

2. **Redirect URI Mismatch**: Verify that the redirect URIs in Cognito and social identity providers match exactly.

3. **Token Verification Errors**: Check that the JWT verification in the middleware is using the correct secret.

4. **Social Identity Provider Errors**: Ensure that the client IDs and secrets are correctly configured in both Cognito and your application.

### Debugging Tips

1. Check the browser console for errors related to authentication.

2. Enable debug logging in AWS Amplify:

```javascript
Amplify.Logger.LOG_LEVEL = 'DEBUG';
```

3. Monitor the Cognito User Pool in the AWS Console for sign-in attempts and errors.

4. Use the AWS CloudTrail to track API calls related to Cognito.

## Additional Resources

- [Amazon Cognito Documentation](https://docs.aws.amazon.com/cognito/)
- [AWS Amplify Authentication Documentation](https://docs.amplify.aws/lib/auth/getting-started/)
- [NextAuth.js Documentation](https://next-auth.js.org/)
