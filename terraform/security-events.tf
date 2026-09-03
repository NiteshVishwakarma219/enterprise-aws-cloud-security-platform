resource "aws_cloudwatch_event_rule" "securityhub_findings" {
  count = var.enable_securityhub ? 1 : 0

  name        = "${local.name_prefix}-securityhub-findings"
  description = "Captures Security Hub findings"

  event_pattern = jsonencode({
    source = [
      "aws.securityhub"
    ]
    detail-type = [
      "Security Hub Findings - Imported"
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-securityhub-findings"
    }
  )
}

resource "aws_cloudwatch_event_target" "securityhub_sns" {
  count = var.enable_securityhub ? 1 : 0

  rule = aws_cloudwatch_event_rule.securityhub_findings[0].name
  arn  = aws_sns_topic.security_alerts.arn
}

resource "aws_sns_topic_policy" "security_alerts" {
  arn = aws_sns_topic.security_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEventBridgePublish"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "sns:Publish"
        Resource = aws_sns_topic.security_alerts.arn
      }
    ]
  })
}