variable "db_username" {
  description = "RDS database username"
  type        = string
}

variable "db_password" {
  description = "RDS database password"
  type        = string
  sensitive   = true
}

variable "db_subnet_group_name" {
  type = string
}

variable "environment" {
  description = "Deployment environment (dev or prod)"
  type        = string
}

variable "rds_sg_id" {
  type = string
}

variable "app_name" {
  description = "Project application name"
  type        = string
}

variable "db_name" {
  description = "Name of the db inside RDS instance"
  type        = string
}

variable "db_instance_class" {
  description = "Instance type"
  type        = string
}

variable "allocated_storage" {
  description = "Allocated db storage"
  type        = number
}

variable "engine_version" {
  description = "Db engine version"
  type        = string
}

variable "storage_type" {
  description = "Db storage type"
  type        = string
}

variable "multi_az" {
  description = "Whether to deploy a standby replica in a 2nd az for auto failover. True for prod, False for dev/staging"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
description = "If true no final snapshot upon db instance deletion. Should be false in prod to prevent accidental data loss in teardown"
type        = bool
}

variable "deletion_protection" {
description = "Should be true in prod as a safeguard against accidental deletion"
type        = bool
}