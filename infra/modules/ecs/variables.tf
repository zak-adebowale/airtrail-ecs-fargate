variable "execution_role_arn" {
  description = "IAM ECS execution role arn"
  type        = string
}

variable "ecr_repo" {
  description = "ECR repo image"
  type = string
}

variable "db_username" {
  description = "RDS master username"
  type        = string 
  sensitive   = true
}

variable "db_password" {
  description = "RDS master password"
  type        = string 
  sensitive   = true
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