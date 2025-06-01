terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "~> 2.30.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.9.0"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.ccloud_api_key
  cloud_api_secret = var.ccloud_api_secret
} 