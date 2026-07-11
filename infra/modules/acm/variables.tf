variable "domain_name" {
  description = "Domain name"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev or prod)"
  type        = string
}

variable "zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
}

variable "app_name" {
  description = "Project application name"
  type        = string
}

variable "dns_ttl" {
  description = "Domain DNS TTL in seconds"
  type        = number
}