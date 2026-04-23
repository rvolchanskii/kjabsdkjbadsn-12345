terraform {
  required_version = "= 1.12.2"

  required_providers {
    dns = {
      source  = "registry.terraform.io/hashicorp/dns"
      version = "3.3.2"
    }

    dns2api = {
      source  = "dns2api.s3.mds.yandex.net/dns/dns2-api"
      version = ">= 0.0.4"
    }
  }
}

provider "dns2api" {
  debug = true
}
