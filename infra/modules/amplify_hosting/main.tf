resource "aws_amplify_app" "this" {
  count = var.enabled ? 1 : 0

  name                 = var.app_name
  repository           = var.repository != "" ? var.repository : null
  platform             = var.platform
  access_token         = var.access_token != "" ? var.access_token : null
  iam_service_role_arn = var.service_role_arn != "" ? var.service_role_arn : null
  build_spec           = var.build_spec != "" ? var.build_spec : null

  environment_variables = var.environment_variables
  tags                  = var.tags
}

resource "aws_amplify_branch" "this" {
  count = var.enabled ? 1 : 0

  app_id            = aws_amplify_app.this[0].id
  branch_name       = var.branch_name
  stage             = "PRODUCTION"
  enable_auto_build = var.repository != "" ? true : false
}
