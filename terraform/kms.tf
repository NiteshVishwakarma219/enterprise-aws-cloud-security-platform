resource "aws_kms_key" "security" {
  description             = "KMS key for NexOps Cloud Security"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-kms"
    }
  )
}

resource "aws_kms_alias" "security" {
  name          = "alias/${local.name_prefix}"
  target_key_id = aws_kms_key.security.key_id
}