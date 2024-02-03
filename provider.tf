terraform {
  cloud {
    organization = "mongj"

    workspaces {
      name = "intern-go-where"
    }
  }
  required_providers {
    hcp = {
      source  = "hashicorp/hcp"
      version = "0.82.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.35.0"
    }
  }
}

provider "hcp" {
  client_id     = var.HCP_CLIENT_ID
  client_secret = var.HCP_CLIENT_SECRET
}

provider "aws" {
  region     = "ap-southeast-1"
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

data "hcp_vault_secrets_app" "igw" {
  app_name = "intern-go-where"
}