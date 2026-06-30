output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.airtrail_alb.dns_name
}

output "ecr_repository_url" {
  description = "ECR repo URL"
  value       = aws_ecr_repository.airtrail_url
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.db_instance.main.endpoint
  sensitive   = true
}

output "app_url" {
  description = "App URL"
  value       = "https://airtrail.adebowale.co.uk"
}