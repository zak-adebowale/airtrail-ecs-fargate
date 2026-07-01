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