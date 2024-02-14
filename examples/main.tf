terraform {
  required_version = ">=1.2.3"

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    local = {
      version = "~> 2.1"
    }
  }
}

/**
 * Configure the default AWS Provider
 */
provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

/**
 * Data sources for VPC information
 */

data "aws_vpc" "default" {
  filter {
    name   = "tag:Name"
    values = ["Your VPC"]

  }
}

data "aws_subnet" "private_1" {
  vpc_id = data.aws_vpc.default.id
  filter {
    name   = "tag:Name"
    values = ["Your Subnet A"]
  }
}

data "aws_subnet" "private_2" {
  vpc_id = data.aws_vpc.default.id
  filter {
    name   = "tag:Name"
    values = ["Your Subnet B"]
  }
}

data "aws_s3_bucket" "log" {
  bucket = "Your log bucket"
}

/**
 * Configure Locals
 */
locals {
  default_tags = {
    "Project"     = var.project
    "Environment" = var.environment
    "Repo"        = var.repo_url
    "Region"      = var.region
    "ShortSha"    = var.git_commit
    "Release"     = var.release
    "Account"     = var.aws_account
  }
  name = "${var.project}-${var.environment}"
}

// Create the actual role policy used by MWAA

resource "aws_iam_policy" "mwaa" {
  name = "datalake-access-${local.name}"

  policy = jsonencode(
    {
      // Your additional policy here :)
    }
  )
}

/* 
 * MWAA
 */

module "mwaa_environment" {
    source = "../"
    name   = "${var.project}-${var.environment}" 
    project_description = "My test environment."
    region = var.region
    aws_account = var.aws_account
    mwaa_bucket_name = "${var.project}-${var.aws_account}-${var.environment}" 
    mwaa_web_allowed_cidr = var.mwaa_web_allowed_cidr
    s3_log_bucket = data.aws_s3_bucket.log.id
    default_tags = local.default_tags
    subnet_ids = [ data.aws_subnet.private_1.id, data.aws_subnet.private_2.id ]
    vpc_cidr_blocks = [data.aws_vpc.default.cidr_block]
    vpc_id = data.aws_vpc.default.id
    iam_policy_arn = aws_iam_policy.mwaa.arn
}