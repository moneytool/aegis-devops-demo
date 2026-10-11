# A tiny "production" stack for the Aegis-DevOps demo.
#
# Nothing here ever talks to AWS: the provider has fake credentials, the plan
# runs with -refresh=false against the committed terraform.tfstate, and no
# workflow ever applies. Open a pull request that removes the database below
# and watch the Aegis-DevOps Plan Check block it.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "demo-not-a-real-key"
  secret_key                  = "demo-not-a-real-secret"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
}

resource "aws_s3_bucket" "assets" {
  bucket = "aegis-devops-demo-assets"
}
