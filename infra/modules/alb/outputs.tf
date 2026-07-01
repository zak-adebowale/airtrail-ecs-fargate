output "alb_arn" {
  value = aws_lb.airtrail_alb.arn
}

output "alb_dns_name" {
  description = "ALB DNS name for Route 53 A record"
  value = aws_lb.airtrail_alb.dns_name
}

output "alb_zone_id" {
  description = "ALB hosted zone ID for Route 53 A record"
  value = aws_lb.airtrail_alb.zone_id
}

output "target_group_arn" {
  description = "Target group ARN for ECS"
  value = aws_lb_target_group.alb_tg.arn
}

output "https_listener_arn" {
  description = "HTTPS listener ARN"
  value = aws_lb_listener.https.arn
}