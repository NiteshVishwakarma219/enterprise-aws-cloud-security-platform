resource "aws_cloudwatch_log_metric_filter" "rejected_traffic" {
  name           = "${local.name_prefix}-rejected-traffic"
  log_group_name = aws_cloudwatch_log_group.vpc_flow_logs.name
  pattern        = "[version, account, eni, source, destination, srcport, destport, protocol, packets, bytes, start, end, action=\"REJECT\", status]"

  metric_transformation {
    name      = "${local.name_prefix}-rejected-traffic"
    namespace = "NexOps/Security"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "rejected_traffic" {
  alarm_name          = "${local.name_prefix}-rejected-traffic"
  alarm_description   = "Detects rejected VPC traffic"
  namespace           = "NexOps/Security"
  metric_name         = "${local.name_prefix}-rejected-traffic"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 5
  comparison_operator = "GreaterThanOrEqualToThreshold"

  alarm_actions = [
    aws_sns_topic.security_alerts.arn
  ]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-rejected-traffic"
    }
  )
}