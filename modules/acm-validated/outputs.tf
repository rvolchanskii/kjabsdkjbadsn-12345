output "certificate_arn" {
  description = "ARN of the validated ACM certificate"
  value       = aws_acm_certificate.certificate.arn
}

output "certificate_status" {
  description = "Status of the certificate"
  value       = aws_acm_certificate.certificate.status
}
