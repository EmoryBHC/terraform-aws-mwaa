output "mwa_bucket" {
  value       = module.mwaa_bucket.s3_bucket_id
  description = "S3 bucket used to store MWAA artifacts"
}

output "mwa_environment_id" {
  value       = aws_mwaa_environment.mwaa.id
  description = "MWAA environment id"
}

output "mwa_environment_arn" {
  value       = aws_mwaa_environment.mwaa.arn
  description = "MWAA environment arn"
}

output "mwa_security_group_id" {
  value       = aws_mwaa_environment.mwaa.id
  description = "MWAA environment security group id"
}

output "mwa_iam_role_name" {
  value       = aws_iam_role.mwaa.name
  description = "MWAA environment IAM role name"
}