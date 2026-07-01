variable "db_username" {
  description = "RDS database username"
  type        = string
}

variable "db_password" {
  description = "RDS database password"
  type        = string
}

variable "db_subnet_group_name" {
  type = string
}

variable "rds_sg_id" {
  type = string
}