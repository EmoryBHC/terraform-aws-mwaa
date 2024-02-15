# Required variables for terraform project

variable "name" {
  description = "Project name."
  type        = string
}

variable "project_description" {
  description = "Project description."
  type        = string
}

variable "environment" {
  description = "Project environment."
  default     = "dev"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "aws_account" {
  description = "Target AWS account."
  type        = string
}

variable "default_tags" {
  description = "Map of default tags to assign to resources."
  type        = map
  default     = {}
}

variable "airflow_configuration_options" {
  type = map
  default = { }
  description = "Map of configuration options used to customize MWAA configuration."
}

variable "mwaa_secrets" {
  type = map
  default = {}
  description = "Map of secrets to created and permitted for use by the MWAA environment."
}

variable "mwaa_secret_values" {
  type = map
  default = {}
  description = "Map of secret to value configuration.  Useful for setting global variables within Airflow.  Never use for secrets that should be kept secret.  Those should be manually set, and never stored in GIT."
}

variable "airflow_version" {
  type = string
  default = "2.5.1"
  description = "Airflow version of the environment."
}

variable "environment_class" {
  type = string
  default = "mw1.small"
  description = "Compute class for environment.  Options are m1.small, m1.medium, and m1.large."
}

variable "max_workers" {
  type = number
  default = 10
  description = "Maximum number of workers to be running at a time."
}

variable "min_workers" {
  type = number
  default = 1
  description = "Minimum number of workers to be running at a time."
}

variable "schedulers" {
  type = number
  default = 2  # Must be > 1 for version 2.5.1 
  description = "The number of schedulers to run in your environment."
}

variable "vpc_id" {
  type        = string
  description = "VPC to restrict MWAA traffic to."  
}

variable "vpc_cidr_blocks" {
  type        = list
  description = "VPC CIDR block used to allow traffic from the scheduler and Aurora DB." 
}

variable "mwaa_web_allowed_cidr" {
  type  = list
  description = "List of allowed CIDR blocks for the MWAA web server."
}

variable "subnet_ids" {
  type = list
  description = "List of subnet ID's you want route your MWAA traffic over."

}

variable "mwaa_bucket_name" {
  type = string
  description = "Name of the S3 bucket you want to store your Airflow source code in."
}

variable "s3_log_bucket" {
  type = string
  description = "Name of the S3 log bucket you want to configure for the bucket defined in the `mwaa_bucket_name` parameter."  
}

variable "iam_policy_arn" {
  type = string
  description = "IAM Policy ARN you would like attach to the MWAA role to provide additional privileges."  
}

variable "s3_force_destroy" {
  type = bool
  default = false
  description = "Should the dag, plugins, and requirements s3 bucket be destroyed when the environment is even if there are objects."
}