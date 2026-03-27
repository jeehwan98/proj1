locals {
  name_prefix = "${var.app_name}-${var.environment}"

  common_tags = {
    App         = var.app_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  azs = ["${var.aws_region}a", "${var.aws_region}b"]

  oidc = {
    # google url where users are redirected to log in. ALB sends users here when they're not authenticated
    authorization_endpoint = "https://accounts.google.com/o/auth2/v2/auth"
    # after login, google sends a code back. the ALB exchanges that code for an access token at this url
    token_endpoint = "https://oauth2.googleapis.com/token"
    # ALB calls this to get the user's profile (email, name) using the access token
    user_info_endpoint = "https://www.googleapis.com/oauth2/v3/userinfo"
    # tells ALB that Google is the trusted identity provider. used to validate tokens
    issuer = "https://accounts.google.com"
    # what info the ALB requests from Google about the user (identity, email, basic profile)
    scope = "openid email profile"
    # name of the browser cookie the ALB sets after a successful login. used to remember the session so users don't have to log in every request
    session_cookie_name = "jee-auth"
    # how long the session lasts in seconds
    session_timeout = 86400 # 8 hours
    # what ALB does when an unauthenticated user hits the app
    # - "authenticate" means redirect them to Google login automatically
    on_unauthenticated_request = "authenticate"
  }
}
