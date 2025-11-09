aws_region  = "ap-northeast-1"
project     = "coingames"
environment = "dev"

default_tags = {
  Owner = "codex"
}

enable_lambda          = true
lambda_package_path    = "../backend/dist/main.zip"
lambda_handler         = "main.handler"
lambda_runtime         = "nodejs18.x"
lambda_memory_size     = 512
lambda_timeout         = 10
lambda_environment     = {}

enable_api_gateway        = true
api_gateway_stage_name    = "$default"
api_gateway_allowed_origins = ["*"]

enable_amplify_hosting = true
amplify_repository     = ""
amplify_access_token   = ""
amplify_branch         = "main"
