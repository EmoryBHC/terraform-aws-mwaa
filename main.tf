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

/*
 * Preload the MWAA Environment S3 Buckets with the contents of the dev, stage prod environment buckets
 */


resource "terraform_data" "s3_objects" {
  triggers_replace = [
    module.mwaa_bucket
  ]

  provisioner "local-exec" {
    command = "aws s3 sync s3://gindata-${var.aws_account}-mwaa-${var.region}-${var.environment} s3://${var.mwaa_bucket_name} --sse"
  }

  depends_on = [ module.mwaa_bucket ]
}

/*
 * MWAA Environment
 */ 

resource "aws_mwaa_environment" "mwaa" {
  dag_s3_path           = "dags/"
  plugins_s3_path       = "plugins/plugins.zip"
  requirements_s3_path  = "requirements/requirements.txt"
  execution_role_arn    = aws_iam_role.mwaa.arn
  environment_class     = var.environment_class
  max_workers           = var.max_workers 
  min_workers           = var.min_workers
  schedulers            = var.schedulers 

  logging_configuration {
    dag_processing_logs {
      enabled   = true
      log_level = "INFO"
    }
    scheduler_logs {
      enabled   = true
      log_level = "INFO"
    }
    task_logs {
      enabled   = true
      log_level = "INFO"
    }
    webserver_logs {
      enabled   = true
      log_level = "ERROR"
    }
    worker_logs {
      enabled           = true
      log_level         = "ERROR"
    }
  }

  name = var.name

  airflow_configuration_options = {
    "secrets.backend"       = "airflow.providers.amazon.aws.secrets.secrets_manager.SecretsManagerBackend"
    "secrets.backend_kwargs" = "{\"connections_prefix\" : \"airflow/${var.name}/connections\", \"variables_prefix\" : \"airflow/${var.name}/variables\"}"
  }

  network_configuration {
    security_group_ids  = [aws_security_group.mwaa.id]
    subnet_ids          = var.subnet_ids 
  }

  source_bucket_arn     = module.mwaa_bucket.s3_bucket_arn
  tags                  = merge({ Name = "${var.name}" }, var.default_tags)

  depends_on = [
    aws_iam_role_policy_attachment.wma,
    terraform_data.s3_objects
  ]

}

/*
 * Security group configuration
 */ 

resource "aws_security_group" "mwaa" {
  name        = var.name
  description = "MWAA Security group"
  vpc_id      = var.vpc_id

  ingress {
    description      = "TLS from allowed blocks"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = var.mwaa_web_allowed_cidr
  }

  ingress {
    description      = "Amazon Aurora PostgreSQL metadata database required by Scheduler"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    cidr_blocks      = var.vpc_cidr_blocks
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = var.default_tags 
}

resource "aws_security_group_rule" "example" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  source_security_group_id = aws_security_group.mwaa.id
  security_group_id = aws_security_group.mwaa.id
}

/*
 * Secrets
 */

resource "aws_secretsmanager_secret" "mwaa" {
  for_each    = var.mwaa_secrets
  name        = each.key
  description = each.value
}

resource "aws_secretsmanager_secret_version" "mwaa" {
  for_each    = var.mwaa_secret_values
  secret_id     = each.key
  secret_string = each.value
  depends_on = [
    aws_secretsmanager_secret.mwaa
  ]  
}

resource "aws_secretsmanager_secret" "mwaa_connections" {
  name        = "airflow/${var.name}/connections"
  description = "MWAA environment and version information"
}

resource "aws_secretsmanager_secret" "mwaa_variables" {
  name        = "airflow/${var.name}/variables"
  description = "MWAA environment and version information"
}

resource "aws_secretsmanager_secret" "mwaa_tags" {
  name        = "airflow/variables/${var.name}/mwaa_config"
  description = "MWAA environment and version information"
}

resource "aws_secretsmanager_secret_version" "mwaa_tags" {
  secret_id     = aws_secretsmanager_secret.mwaa_tags.id
  secret_string = jsonencode(var.default_tags)
}

/*
 * S3
 */

data "aws_s3_bucket" "log" {
  bucket = var.s3_log_bucket
}

data "aws_iam_policy_document" "allow_log_delivery" {
  statement {
    sid = "S3ServerAccessLogsPolicy"
    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${data.aws_s3_bucket.log.arn}/logs/*"
    ]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [var.aws_account]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values = [
        module.mwaa_bucket.s3_bucket_arn
      ]
    }
  }
}

data "aws_iam_policy_document" "mwaa_bucket_policy" {
  source_policy_documents = [
    templatefile("${path.module}/templates/enforce_s3_sse.tftpl", {
      s3_bucket_arn    = module.mwaa_bucket.s3_bucket_arn
    })
  ]
}

/* 
 * MWAA Bucket for Dags and Pluginsd
 */

module "mwaa_bucket" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  # version       = "3.4.0"
  bucket        = var.mwaa_bucket_name
  force_destroy = false
  tags          = merge({ Name = "${var.mwaa_bucket_name}" }, var.default_tags)

  # Security settings
  attach_deny_insecure_transport_policy = true
  block_public_acls                     = true
  block_public_policy                   = true
  ignore_public_acls                    = true
  restrict_public_buckets               = true

  # ACLs are no longer recommended for securing S3.  Instead, enforce ownership
  # and attach a bucket policy
  # https://docs.aws.amazon.com/AmazonS3/latest/userguide/ensure-object-ownership.html
  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"
  attach_policy            = true
  policy                   = data.aws_iam_policy_document.mwaa_bucket_policy.json

  versioning = {
    status = true
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  # S3 data API access logging
  logging = {
    target_bucket = var.s3_log_bucket
    # Including bucket name enables direct access to a specific bucket *AND*
    # allows for retention of logs by bucket (e.g. raw access logs might only be useful for 7-14 days)
    target_prefix = "var.mwaa_bucket_name"
  }
}