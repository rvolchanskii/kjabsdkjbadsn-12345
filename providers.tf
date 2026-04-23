terraform {
  required_version = "1.12.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.100.0"
    }

    dns = {
      source  = "registry.terraform.io/hashicorp/dns"
      version = "3.3.2"
    }

    dns2api = {
      source  = "dns2api.s3.mds.yandex.net/dns/dns2-api"
      version = "0.0.4"
    }
  }

  backend "s3" {
    bucket = "aws-taxi-cdn-tfstate"
    key    = "terraform.tfstate"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {}
  }
}

# US-East-1 provider for ACM certificates (required for CloudFront)
provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

provider "dns2api" {
  debug = true
}
