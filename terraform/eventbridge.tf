resource "aws_cloudwatch_event_rule" "security_events" {
  name        = "${local.name_prefix}-security-events"
  description = "Captures AWS security service events"

  event_pattern = jsonencode({
    source = [
      "aws.guardduty",
      "aws.securityhub"
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-security-events"
    }
  )
}

resource "aws_cloudwatch_event_target" "security_sns" {
  rule = aws_cloudwatch_event_rule.security_events.name
  arn  = aws_sns_topic.security_alerts.arn
}