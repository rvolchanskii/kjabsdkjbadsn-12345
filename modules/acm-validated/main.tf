resource "aws_acm_certificate" "certificate" {
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  validation_method         = "DNS"

  tags = var.tags
}

resource "dns2api_records" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options :
    dvo.domain_name => dvo
  }

  fqdn = each.value.resource_record_name

  record {
    ttl  = 3600
    type = each.value.resource_record_type
    data = each.value.resource_record_value
  }
}

resource "aws_acm_certificate_validation" "validation" {
  certificate_arn = aws_acm_certificate.certificate.arn

  depends_on = [dns2api_records.validation]
}
