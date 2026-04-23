terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.99.0"
    }
    dns2api = {
      source  = "dns2api.s3.mds.yandex.net/dns/dns2-api"
      version = ">= 0.0.3"
    }
  }
}
