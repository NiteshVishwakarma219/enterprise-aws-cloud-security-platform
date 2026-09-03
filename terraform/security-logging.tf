resource "aws_cloudwatch_log_group" "security" {
  name              = "/nexops/${local.name_prefix}/security"
  retention_in_days = var.security_log_retention_days

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-security-logs"
    }
  )
}