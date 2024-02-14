output "mwa_bucket" {
  value       = module.mwaa_bucket.s3_bucket_id
  description = "S3 bucket used to store MWAA artifacts"
}