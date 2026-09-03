resource "aws_guardduty_detector" "security" {
  count = var.enable_guardduty ? 1 : 0

  enable = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-guardduty"
    }
  )
}