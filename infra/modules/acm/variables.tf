variable "domain_name" {
  description = "Domain name"
  type        = string 
}

variable "zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
}

variable "alb_dns_name" {
  description = "ALB DNS name"
  type        = string
}

variable "alb_zone_id" {
  description = "ALB zone ID"
  type        = string
}

variable "app_name" {
  description = "Project application name"
  type        = string
}