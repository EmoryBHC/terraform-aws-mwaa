# Required variables for terraform project

variable "project" {
  description = "Project name."
  type        = string
  default     = "test-env"
}

variable "project_description" {
  description = "Project description."
  type        = string
  default     = "My development MWAA Environment"
}

variable "environment" {
  description = "Project environment."
  default     = "dev"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "aws_account" {
  description = "Target AWS account."
  type        = string
  default     = "12345678901"
}

variable "repo_url" {
  type        = string
  default     = "git://github.com/EmoryBHC/terraform-aws-mwaa.git"
  description = "Git repository URL.  Will be tagged to resources for traceability"
}

variable "git_commit" {
  type        = string
  default     = "local-run"
  description = "Short SHA hash of the current git commit.  Will be tagged to resources for traceability"
}

variable "release" {
  type        = string
  default     = "local-run"
  description = "Branch name or release tag.  Will be tagged to resources for traceability"
}

variable "mwaa_web_allowed_cidr" {
  type  = list
  default = ["10.10.0.0/16"]
  description = "List of allowed CIDR blocks for the MWAA web server."
}
