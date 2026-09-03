resource "aws_securityhub_account" "security" {
  count = var.enable_securityhub ? 1 : 0

  enable_default_standards = true
  auto_enable_controls     = true
}