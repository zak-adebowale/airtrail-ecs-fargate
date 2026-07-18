variable "execution_role_arn" {
  description = "IAM ECS execution role arn"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev or prod)"
  type        = string
}

variable "ecr_repo" {
  description = "ECR repo image"
  type        = string
}

variable "domain_name" {
  description = "Domain name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "ecs_sg_id" {
  description = "ECS security group ID"
  type        = list(string)
}

variable "alb_target_group_arn" {
  description = "ALB target group arn"
  type        = string
}

variable "db_url" {
  description = "Database connection string"
  type        = string
  sensitive   = true
}

variable "app_name" {
  description = "Project application name"
  type        = string
}

variable "health_check_path" {
  description = "ALB health check path"
  type        = string
}

variable "container_port" {
  description = "Port the app container runs on"
  type        = number
}

variable "cpu" {
  description = "App container cpu"
  type        = number
}

variable "memory" {
  description = "App container memory in MiB"
  type        = number
}

variable "log_retention_days" {
  description = "The number of days Cloudwatch logs are retained"
  type        = number
}

variable "desired_count" {
  description = "Number of tasks running"
  type        = number
}