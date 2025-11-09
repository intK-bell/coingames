terraform {
  backend "s3" {}
}

# Remote state bucket/lock table are bootstrapped via infra/bootstrap.
