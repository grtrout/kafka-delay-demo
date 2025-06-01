# Infrastructure outputs
output "environment_id" {
  description = "Confluent Cloud Environment ID"
  value       = confluent_environment.main.id
}

output "kafka_cluster_id" {
  description = "Kafka cluster ID"
  value       = confluent_kafka_cluster.main.id
}

output "kafka_bootstrap_servers" {
  description = "Kafka cluster bootstrap servers"
  value       = confluent_kafka_cluster.main.bootstrap_endpoint
}

output "schema_registry_id" {
  description = "Schema Registry cluster ID"
  value       = data.confluent_schema_registry_cluster.main.id
}

output "schema_registry_url" {
  description = "Schema Registry REST endpoint"
  value       = data.confluent_schema_registry_cluster.main.rest_endpoint
}

output "flink_compute_pool_id" {
  description = "Flink compute pool ID"
  value       = confluent_flink_compute_pool.main.id
}

# Service account outputs
output "app_service_account_id" {
  description = "Application service account ID"
  value       = confluent_service_account.app.id
}

output "flink_service_account_id" {
  description = "Flink service account ID"
  value       = confluent_service_account.flink.id
}

# API key outputs (sensitive)
output "app_kafka_api_key" {
  description = "Application Kafka API key"
  value       = confluent_api_key.app_kafka.id
  sensitive   = true
}

output "app_kafka_api_secret" {
  description = "Application Kafka API secret"
  value       = confluent_api_key.app_kafka.secret
  sensitive   = true
}

output "app_schema_registry_api_key" {
  description = "Application Schema Registry API key"
  value       = confluent_api_key.app_schema_registry.id
  sensitive   = true
}

output "app_schema_registry_api_secret" {
  description = "Application Schema Registry API secret"
  value       = confluent_api_key.app_schema_registry.secret
  sensitive   = true
}

# Flink automation status
output "flink_statements" {
  description = "Automated Flink SQL statement names"
  value = {
    orders_table         = confluent_flink_statement.orders_table.statement_name
    processed_orders_table = confluent_flink_statement.processed_orders_table.statement_name
    delay_processor      = confluent_flink_statement.delay_processor.statement_name
  }
} 