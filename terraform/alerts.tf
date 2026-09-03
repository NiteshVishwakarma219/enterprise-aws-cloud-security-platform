resource "aws_sns_topic" "security_alerts" {
  name = "${local.name_prefix}-alerts"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-security-alerts"
    }
  )
}

resource "aws_sns_topic_subscription" "security_email" {
  count = var.security_alert_email != "" ? 1 : 0

  topic_arn = aws_sns_topic.security_alerts.arn
  protocol  = "email"
  endpoint  = var.security_alert_email
}