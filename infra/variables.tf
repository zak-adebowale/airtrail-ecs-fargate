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
  description = "Domain DNS TTL"
  type        = string
  default     = "60"
}