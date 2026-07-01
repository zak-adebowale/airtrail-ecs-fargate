output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.airtrail_alb.dns_name
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = module.db.rds_endpoint
  sensitive   = true
}

output "app_url" {
  description = "App URL"
  value       = "https://airtrail.adebowale.co.uk"
}