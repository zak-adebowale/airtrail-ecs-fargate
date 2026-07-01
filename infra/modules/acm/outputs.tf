output "zone_id" {
  value = data.aws_route53_zone.airtrail_route53_zone.id
}

output "cert_validation_arn" {
  value = aws_acm_certificate_validation.acm_cert_validation.certificate_arn
}
