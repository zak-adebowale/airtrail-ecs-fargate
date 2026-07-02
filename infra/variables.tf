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

variable "github_org" {
  description = "GitHub username"
  type        = string
}

variable "repo_name" {
  description = "Repo name"
  type        = string
}

variable "domain_name" {
  description = "Domain name"
  type        = string 
}

variable "app_name" {
  description = "Project application name"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "Public subnet 1 CIDR block"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "Public subnet 2 CIDR block"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_1_cidr" {
  description = "Private subnet 1 CIDR block"
  type        = string
  default     = "10.0.3.0/24"
}

variable "private_subnet_2_cidr" {
  description = "Private subnet 2 CIDR block"
  type        = string
  default     = "10.0.4.0/24"
}

variable "az_1" {
  description = "Availability zone 1"
  type        = string 
  default     = "eu-west-2a"
}

variable "az_2" {
  description = "Availability zone 2"
  type        = string 
  default     = "eu-west-2b"
}

variable "all_ip_cidr" {
  description = "All IPv4 addresses"
  type        = string
  default     = "0.0.0.0/0"
}

variable "dns_ttl" {
  description = "Domain DNS TTL in seconds"
  type        = number
  default     = "60"
}

variable "db_instance_class" {
  description = "Instance type"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Allocated db storage"
  type        = string
  default     = "20"
}

variable "engine_version" {
  description = "Db engine version"
  type        = string
  default     = "16.14"
}

variable "storage_type" {
  description = "Db storage type"
  type        = string
  default     = "gp3"
}

variable "db_name" {
  description = "Name of the db inside RDS instance"
  type        = string
  default     = "airtrail"
}

variable "multi_az" {
  description = "Whether to deploy a standy replica in a 2nd az for auto failover. True for prod, False for dev/staging"
  type        = bool
  default     = "false"
}

variable "skip_final_snapshot" {
description = "If true no final snapshot upon db instance deletion. Should be false in prod to prevent accidental data loss in teardown"
type        = bool
default     = true
}

variable "deletion_protection" {
description = "Should be true in prod as a safeguard against accidental deletion"
type        = bool
default     = false
}

variable "container_port" {
description = "Port the app container runs on"
type        = number
default     = 3000
}

variable "health_check_path" {
  description = "ALB health check path"
  type        = string
  default     = "/api/ping"
}

variable "ssl_policy" {
  description = "Web traffic ssl policy"
  type        = string
}

variable "container_cpu" {
description = "App container cpu"
type        = number
default     = 1024
}

variable "container_memory" {
description = "App container memory in MiB"
type        = number
default     = 2048
}

variable "retention_days" {
description = "Number of days Cloudwatch logs are retained"
type        = number
default     = 7
}

variable "desired_count" {
description = "Number of tasks running"
type        = number
default     = 1
}


