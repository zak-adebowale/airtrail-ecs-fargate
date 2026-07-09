variable "github_org" {
  description = "GitHub username"
  type        = string
}

variable "repo_name" {
  description = "Repo name"
  type        = string
}

variable "app_name" {
  description = "Project application name"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev or prod)"
  type        = string
}

variable "oidc_provider_arn" {
  description = "Arn for the IIDC provider"
  type        = string
}