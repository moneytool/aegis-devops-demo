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

resource "aws_db_instance" "orders" {
  identifier                  = "orders-prod"
  engine                      = "postgres"
  engine_version              = "16.4"
  instance_class              = "db.t4g.micro"
  allocated_storage           = 20
  username                    = "orders"
  manage_master_user_password = true # RDS keeps the password in Secrets Manager
  skip_final_snapshot         = true

  # provider defaults, spelled out so an unchanged plan really shows no changes
  apply_immediately            = false
  auto_minor_version_upgrade   = true
  copy_tags_to_snapshot        = false
  dedicated_log_volume         = false
  delete_automated_backups     = true
  monitoring_interval          = 0
  performance_insights_enabled = false
  publicly_accessible          = false
}

resource "aws_s3_bucket" "assets" {
  bucket = "aegis-devops-demo-assets"
}
