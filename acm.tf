# ACM Certificate
resource "aws_acm_certificate" "prod" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  subject_alternative_names = [
    var.backend_domain_name
  ]
  lifecycle {
    create_before_destroy = true
  }
}

# Route 53 Zone
data "aws_route53_zone" "prod" {
  name = var.domain_name
}

# DNS Validation Record
resource "aws_route53_record" "prod" {
  for_each = {
    for dvo in aws_acm_certificate.prod.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.aws_route53_zone.prod.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 300
  records = [each.value.record]
}

# ACM Certificate Validation
resource "aws_acm_certificate_validation" "prod" {
  certificate_arn         = aws_acm_certificate.prod.arn
  validation_record_fqdns = [for record in aws_route53_record.prod : record.fqdn]
}

