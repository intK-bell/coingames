locals {
  project_prefix = "${var.project}-${var.environment}"
  common_tags = merge(
    {
      Project     = var.project
      Environment = var.environment
    },
    var.default_tags,
  )
}

module "dynamodb_state" {
  source                   = "./modules/dynamodb_state"
  table_name               = "${local.project_prefix}-game-state"
  partition_key            = { name = "user_id", type = "S" }
  sort_key                 = { name = "entity_type_ts", type = "S" }
  ttl_attribute            = null
  point_in_time_recovery   = true
  enable_stream            = true
  stream_view_type         = "NEW_AND_OLD_IMAGES"
  global_secondary_indexes = []
  tags                     = local.common_tags
}

module "iam_shared" {
  source                     = "./modules/iam_shared"
  project_prefix             = local.project_prefix
  lambda_managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"]
  amplify_managed_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess-Amplify"
  ]
  tags = local.common_tags
}

module "lambda_nest" {
  source        = "./modules/lambda_nest"
  enabled       = var.enable_lambda
  function_name = "${local.project_prefix}-api"
  package_path  = var.lambda_package_path
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  role_arn      = module.iam_shared.lambda_role_arn
  memory_size   = var.lambda_memory_size
  timeout       = var.lambda_timeout
  environment = merge(
    {
      DYNAMODB_TABLE = module.dynamodb_state.table_name
    },
    var.lambda_environment,
  )
  tags = local.common_tags
}

module "api_gateway" {
  source               = "./modules/api_gateway"
  enabled              = var.enable_api_gateway
  name                 = "${local.project_prefix}-http"
  lambda_invoke_arn    = module.lambda_nest.lambda_invoke_arn
  lambda_function_arn  = module.lambda_nest.lambda_function_arn
  stage_name           = var.api_gateway_stage_name
  cors_allowed_origins = var.api_gateway_allowed_origins
  tags                 = local.common_tags
}

module "amplify_hosting" {
  source           = "./modules/amplify_hosting"
  enabled          = var.enable_amplify_hosting
  app_name         = "${local.project_prefix}-app"
  repository       = var.amplify_repository
  access_token     = var.amplify_access_token
  branch_name      = var.amplify_branch
  service_role_arn = module.iam_shared.amplify_role_arn
  environment_variables = {
    VITE_API_BASE_URL = try(module.api_gateway.invoke_url, "")
  }
  tags = local.common_tags
}
