resource "aws_lb" "main" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  enable_deletion_protection = true

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-alb" })
}

resource "aws_lb_target_group" "app" {
  name        = "${local.name_prefix}-tg-app"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
  }

  tags = local.common_tags
}

# HTTP → HTTPS redirect
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS with Google OAuth
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = aws_acm_certificate_validation.main.certificate_arn

  default_action {
    type  = "authenticate-oidc"
    order = 1

    authenticate_oidc {
      authorization_endpoint     = local.oidc.authorization_endpoint
      token_endpoint             = local.oidc.token_endpoint
      user_info_endpoint         = local.oidc.user_info_endpoint
      issuer                     = local.oidc.issuer
      client_id                  = var.google_client_id
      client_secret              = var.google_client_secret
      scope                      = local.oidc.scope
      session_cookie_name        = local.oidc.session_cookie_name
      session_timeout            = local.oidc.session_timeout
      on_unauthenticated_request = local.oidc.on_unauthenticated_request
    }
  }

  default_action {
    type             = "forward"
    order            = 2
    target_group_arn = aws_lb_target_group.app.arn
  }
}
