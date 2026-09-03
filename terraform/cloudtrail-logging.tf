data "aws_iam_policy_document" "cloudtrail_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cloudtrail" {
  name               = "${local.name_prefix}-cloudtrail-role"
  assume_role_policy = data.aws_iam_policy_document.cloudtrail_assume_role.json

  tags = local.common_tags
}

data "aws_iam_policy_document" "cloudtrail" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "${aws_cloudwatch_log_group.security.arn}:*"
    ]
  }
}

resource "aws_iam_role_policy" "cloudtrail" {
  name   = "${local.name_prefix}-cloudtrail-policy"
  role   = aws_iam_role.cloudtrail.id
  policy = data.aws_iam_policy_document.cloudtrail.json
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name              = "/nexops/${local.name_prefix}/cloudtrail"
  retention_in_days = var.cloudtrail_retention_days

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-cloudtrail-logs"
    }
  )
}
