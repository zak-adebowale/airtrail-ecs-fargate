variable "app_name" {
  description = "Project application name"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev or prod)"
  type        = string
}

variable "ecs_execution_policy_arn" {
  description = "ARN for the ECS exec policy role attachment"
  type        = string
  default     = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}