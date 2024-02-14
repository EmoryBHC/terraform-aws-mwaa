/*
 * IAM Policlies and Roles
 */

// MWAA Role

resource "aws_iam_role" "mwaa" {
  name = var.name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode(
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Service": [
                        "airflow-env.amazonaws.com",
                        "airflow.amazonaws.com"
                    ]
                },
                "Action": "sts:AssumeRole"
            }
        ]
    }
  )

  tags = var.default_tags
}

// Create the actual role policy used by MWAA

resource "aws_iam_policy" "mwaa" {
  name = var.name

  policy = jsonencode(
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "PublishMetricsAccess",              
                "Effect": "Allow",
                "Action": "airflow:PublishMetrics",
                "Resource": "arn:aws:airflow:${var.region}:${var.aws_account}:environment/${var.name}"
            },
            {
                "Sid": "DenyListAllMyBucketsAccess",              
                "Effect": "Deny",
                "Action": "s3:ListAllMyBuckets",
                "Resource": [
                    "${module.mwaa_bucket.s3_bucket_arn}",
                    "${module.mwaa_bucket.s3_bucket_arn}/*"
                ]
            },
            {
                "Sid": "MWAABucketAccess",              
                "Effect": "Allow",
                "Action": [
                    "s3:*"
                ],
                "Resource": [     
                    "${module.mwaa_bucket.s3_bucket_arn}",
                    "${module.mwaa_bucket.s3_bucket_arn}/*"
                ]
            },
            {
                "Sid": "LogAccess",              
                "Effect": "Allow",
                "Action": [
                    "logs:CreateLogStream",
                    "logs:CreateLogGroup",
                    "logs:PutLogEvents",
                    "logs:GetLogEvents",
                    "logs:GetLogRecord",
                    "logs:GetLogGroupFields",
                    "logs:GetQueryResults"
                ],
                "Resource": [
                    "arn:aws:logs:${var.region}:${var.aws_account}:log-group:airflow-${var.name}*"
                ]
            },
            {
                "Sid": "LogGroupAccess",              
                "Effect": "Allow",
                "Action": [
                    "logs:DescribeLogGroups"
                ],
                "Resource": [
                    "*"
                ]
            },
            {
                "Sid": "CloudwatchAccess",              
                "Effect": "Allow",
                "Action": "cloudwatch:PutMetricData",
                "Resource": "*"
            },
            {
                "Effect": "Allow",
                "Action": [
                    "sqs:ChangeMessageVisibility",
                    "sqs:DeleteMessage",
                    "sqs:GetQueueAttributes",
                    "sqs:GetQueueUrl",
                    "sqs:ReceiveMessage",
                    "sqs:SendMessage"
                ],
                "Resource": "arn:aws:sqs:${var.region}:*:airflow-celery-*"
            },
            {
                "Sid": "SQSKMS",              
                "Effect": "Allow",
                "Action": [
                    "kms:Decrypt",
                    "kms:DescribeKey",
                    "kms:GenerateDataKey*",
                    "kms:Encrypt"
                ],
                "NotResource": "arn:aws:kms:*:${var.aws_account}:key/*",
                "Condition": {
                    "StringLike": {
                        "kms:ViaService": [
                            "sqs.us-east-1.amazonaws.com"
                        ]
                    }
                }
            },
            {
                "Sid": "SecretsManagerAccess",              
                "Effect": "Allow",
                "Action": [
                    "secretsmanager:GetResourcePolicy",
                    "secretsmanager:GetSecretValue",
                    "secretsmanager:DescribeSecret",
                    "secretsmanager:ListSecretVersionIds"
                ],
                "Resource": "${local.secret_arns}"
            },
            {
                "Sid": "ListSecretsManagerSecretsAccess",              
                "Effect": "Allow",
                "Action": "secretsmanager:ListSecrets",
                "Resource": "*"
            }   
        ]
    }
  )
}

// Locals for slightly more complex permissions can be configured below
locals {
  // Create a resource list to allow MWAA to access any custom secrets or secrets prefixed with airflow/variables or airflow/connections.
  secret_arns = concat(values(aws_secretsmanager_secret.mwaa)[*].arn,["${aws_secretsmanager_secret.mwaa_variables.arn}/*","${aws_secretsmanager_secret.mwaa_connections.arn}/*"])
}

// Attach the role policy used by MWAA
resource "aws_iam_role_policy_attachment" "wma" {
  role      = aws_iam_role.mwaa.name
  policy_arn = aws_iam_policy.mwaa.arn
}

// Attach the additional role policy used by MWAA
resource "aws_iam_role_policy_attachment" "wma-additional" {
  role      = aws_iam_role.mwaa.name
  policy_arn = var.iam_policy_arn
}

