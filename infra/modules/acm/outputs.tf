output "certificate_arn" {
  value = aws_acm_certificate_validation.acm_cert_validation.certificate_arn
}
