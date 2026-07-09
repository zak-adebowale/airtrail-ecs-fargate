variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev or prod)"
  type        = string
}

variable "app_name" {
  description = "Project application name"
  type        = string
}

variable "all_ip_cidr" {
  description = "All IPv4 addresses"
  type        = string
  default     = "0.0.0.0/0"
}