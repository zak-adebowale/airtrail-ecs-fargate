variable "alb_sg_id" {
  description = "ALB security group ID"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "ID of the public subnets"
  type        = list(string)
}

variable "vpc_id" {
  description = "Project VPC ID"
  type        = string
}

variable "certificate_arn" {
  description = "ACM certificate arn"
  type        = string
}

variable "app_name" {
  description = "Project application name"
  type        = string
}

variable "container_port" {
description = "Port the app container runs on"
type        = number
}

variable "health_check_path" {
  description = "ALB health check path"
  type        = string
}

variable "ssl_policy" {
  description = "Web traffic ssl policy"
  type        = string
}