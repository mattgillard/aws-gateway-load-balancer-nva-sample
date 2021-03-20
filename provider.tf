provider "aws" {
  profile    = var.aws-profile
  region     = var.region
  access_key = var.aws-access-key
  secret_key = var.aws-secret-key
}
