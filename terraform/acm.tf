# acm.tf - SSL/TLS certificate for authentication24.com
/**
  ACM issues a free certificate and attaches it to the ALB HTTPS listener.
  Validation is done via DNS — Terraform creates the validation CNAME record
  in Route 53 and waits for ACM to confirm it before marking the cert ready.
*/

resource "aws_acm_certificate" "main" {
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-cert" })
}

# Route 53 hosted zone — must already exist in your AWS account
data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

# DNS validation record — ACM gives us a CNAME to add; we add it via Terraform
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      value  = dvo.resource_record_value
    }
  }

  zone_id         = data.aws_route53_zone.main.zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 60
  records         = [each.value.value]
  allow_overwrite = true
}

# Waits until ACM has verified the DNS record and the certificate is issued
resource "aws_acm_certificate_validation" "main" {
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [for r in aws_route53_record.cert_validation : r.fqdn]
}

# A record — points authentication24.com to the ALB
resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}
