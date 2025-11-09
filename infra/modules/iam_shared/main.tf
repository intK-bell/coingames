locals {
  lambda_role_name  = "${var.project_prefix}-lambda-exec"
  amplify_role_name = "${var.project_prefix}-amplify"
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "amplify_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["amplify.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_execution" {
  name               = local.lambda_role_name
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = var.tags
}

resource "aws_iam_role" "amplify_service" {
  name               = local.amplify_role_name
  assume_role_policy = data.aws_iam_policy_document.amplify_assume_role.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_managed" {
  for_each   = toset(var.lambda_managed_policy_arns)
  role       = aws_iam_role.lambda_execution.name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "amplify_managed" {
  for_each   = toset(var.amplify_managed_policy_arns)
  role       = aws_iam_role.amplify_service.name
  policy_arn = each.value
}
