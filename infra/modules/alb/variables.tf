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