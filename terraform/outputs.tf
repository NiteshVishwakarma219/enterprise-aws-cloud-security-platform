output "project_name" {
  description = "Security project name"
  value       = var.project_name
}

output "aws_account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS region"
  value       = data.aws_region.current.region
}

output "vpc_id" {
  description = "Security VPC ID"
  value       = aws_vpc.security.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "cloudtrail_name" {
  description = "CloudTrail trail name"
  value       = aws_cloudtrail.security.name
}

output "cloudtrail_bucket" {
  description = "CloudTrail S3 bucket"
  value       = aws_s3_bucket.cloudtrail.bucket
}

output "security_log_group" {
  description = "Security CloudWatch log group"
  value       = aws_cloudwatch_log_group.security.name
}

output "vpc_flow_log_id" {
  description = "VPC Flow Log ID"
  value       = aws_flow_log.security.id
}

output "kms_key_arn" {
  description = "KMS security key ARN"
  value       = aws_kms_key.security.arn
}

output "kms_alias" {
  description = "KMS security alias"
  value       = aws_kms_alias.security.name
}

output "security_alert_topic_arn" {
  description = "SNS security alert topic ARN"
  value       = aws_sns_topic.security_alerts.arn
}

output "securityhub_status" {
  description = "Security Hub resource status"
  value       = var.enable_securityhub ? "enabled" : "disabled"
}

output "guardduty_status" {
  description = "GuardDuty configuration status"
  value       = var.enable_guardduty ? "enabled" : "disabled"
}

output "config_recorder_name" {
  description = "AWS Config recorder name"
  value       = aws_config_configuration_recorder.security.name
}

output "config_bucket" {
  description = "AWS Config S3 bucket"
  value       = aws_s3_bucket.config.bucket
}