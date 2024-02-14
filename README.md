# terraform-aws-mwaa
Terraform module for AWS MWAA

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.2.3 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.9.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_mwaa_bucket"></a> [mwaa\_bucket](#module\_mwaa\_bucket) | terraform-aws-modules/s3-bucket/aws | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.mwaa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.mwaa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.wma](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.wma-additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_mwaa_environment.mwaa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/mwaa_environment) | resource |
| [aws_secretsmanager_secret.mwaa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.mwaa_connections](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.mwaa_tags](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.mwaa_variables](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.mwaa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.mwaa_tags](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.mwaa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [terraform_data.s3_objects](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [aws_iam_policy_document.allow_log_delivery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.mwaa_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_s3_bucket.log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account"></a> [aws\_account](#input\_aws\_account) | Target AWS account. | `string` | n/a | yes |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Map of default tags to assign to resources. | `map` | `{}` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Project environment. | `string` | `"dev"` | no |
| <a name="input_environment_class"></a> [environment\_class](#input\_environment\_class) | Compute class for environment.  Options are m1.small, m1.medium, and m1.large. | `string` | `"mw1.small"` | no |
| <a name="input_iam_policy_arn"></a> [iam\_policy\_arn](#input\_iam\_policy\_arn) | IAM Policy ARN you would like attach to the MWAA role to provide additional privileges. | `string` | n/a | yes |
| <a name="input_max_workers"></a> [max\_workers](#input\_max\_workers) | Maximum number of workers to be running at a time. | `number` | `10` | no |
| <a name="input_min_workers"></a> [min\_workers](#input\_min\_workers) | Minimum number of workers to be running at a time. | `number` | `1` | no |
| <a name="input_mwaa_bucket_name"></a> [mwaa\_bucket\_name](#input\_mwaa\_bucket\_name) | Name of the S3 bucket you want to store your Airflow source code in. | `string` | n/a | yes |
| <a name="input_mwaa_secret_values"></a> [mwaa\_secret\_values](#input\_mwaa\_secret\_values) | Map of secret to value configuration.  Useful for setting global variables within Airflow.  Never use for secrets that should be kept secret.  Those should be manually set, and never stored in GIT. | `map` | `{}` | no |
| <a name="input_mwaa_secrets"></a> [mwaa\_secrets](#input\_mwaa\_secrets) | Map of secrets to created and permitted for use by the MWAA environment. | `map` | `{}` | no |
| <a name="input_mwaa_web_allowed_cidr"></a> [mwaa\_web\_allowed\_cidr](#input\_mwaa\_web\_allowed\_cidr) | List of allowed CIDR blocks for the MWAA web server. | `list` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Project name. | `string` | n/a | yes |
| <a name="input_project_description"></a> [project\_description](#input\_project\_description) | Project description. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_s3_log_bucket"></a> [s3\_log\_bucket](#input\_s3\_log\_bucket) | Name of the S3 log bucket you want to configure for the bucket defined in the `mwaa_bucket_name` parameter. | `string` | n/a | yes |
| <a name="input_schedulers"></a> [schedulers](#input\_schedulers) | The number of schedulers to run in your environment. | `number` | `2` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet ID's you want route your MWAA traffic over. | `list` | n/a | yes |
| <a name="input_vpc_cidr_blocks"></a> [vpc\_cidr\_blocks](#input\_vpc\_cidr\_blocks) | VPC CIDR block used to allow traffic from the scheduler and Aurora DB. | `list` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC to restrict MWAA traffic to. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_mwa_bucket"></a> [mwa\_bucket](#output\_mwa\_bucket) | S3 bucket used to store MWAA artifacts |
<!-- END_TF_DOCS -->