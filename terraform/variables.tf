# Confluent Cloud API credentials
variable "ccloud_api_key" {
  type        = string
  description = "Confluent Cloud API Key"
}

variable "ccloud_api_secret" {
  type        = string
  description = "Confluent Cloud API Secret"
  sensitive   = true
}

# Project configuration
variable "project_name" {
  type        = string
  description = "Name prefix for all resources"
  default     = "kafka-delay-demo"
}

# Infrastructure configuration
variable "cloud_provider" {
  type        = string
  description = "Cloud provider for Confluent Cloud resources"
  default     = "AWS"
}

variable "region" {
  type        = string
  description = "Cloud region for Confluent Cloud resources"
  default     = "us-east-1"
}

variable "kafka_availability" {
  type        = string
  description = "Kafka cluster availability (SINGLE_ZONE, MULTI_ZONE)"
  default     = "SINGLE_ZONE"
}

variable "schema_registry_package" {
  type        = string
  description = "Schema Registry package (ESSENTIALS, ADVANCED)"
  default     = "ESSENTIALS"
}

# Flink configuration
variable "flink_max_cfu" {
  type        = number
  description = "Maximum CFUs for Flink compute pool"
  default     = 5
}

variable "schema_registry_wait_time" {
  type        = string
  description = "Time to wait for Schema Registry provisioning"
  default     = "30s"
} 