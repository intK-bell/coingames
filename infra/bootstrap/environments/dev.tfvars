aws_region  = "ap-northeast-1"
project     = "coingames"
environment = "dev"

state_bucket_name     = "coingames-tf-state-dev-aokikensaku"
state_lock_table_name = "coingames-tf-lock-dev"

default_tags = {
  Owner = "codex"
}
