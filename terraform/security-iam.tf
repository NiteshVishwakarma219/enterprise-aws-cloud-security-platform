data "aws_iam_policy_document" "security_audit" {
  statement {
    effect = "Allow"

    actions = [
      "cloudtrail:DescribeTrails",
      "cloudtrail:GetTrailStatus",
      "cloudtrail:LookupEvents",
      "ec2:DescribeInstances",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeNetworkAcls",
      "ec2:DescribeVpcs",
      "ec2:DescribeSubnets",
      "iam:GetAccountSummary",
      "iam:ListUsers",
      "iam:ListRoles",
      "s3:GetAccountPublicAccessBlock",
      "s3:ListAllMyBuckets",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "security_audit" {
  name        = "${local.name_prefix}-security-audit"
  description = "Read-only security auditing permissions for NexOps Cloud Security"
  policy      = data.aws_iam_policy_document.security_audit.json

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-security-audit"
    }
  )
}