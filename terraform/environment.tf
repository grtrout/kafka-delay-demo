# Confluent Cloud Environment with Stream Governance
# Provides Schema Registry functionality for Avro message serialization
resource "confluent_environment" "main" {
  display_name = var.project_name

  stream_governance {
    package = var.schema_registry_package
  }
}

# Wait for Schema Registry to be fully provisioned
resource "time_sleep" "wait_for_schema_registry" {
  depends_on      = [confluent_environment.main]
  create_duration = var.schema_registry_wait_time
}

# Reference to the automatically created Schema Registry cluster
data "confluent_schema_registry_cluster" "main" {
  environment {
    id = confluent_environment.main.id
  }

  depends_on = [
    confluent_environment.main,
    time_sleep.wait_for_schema_registry
  ]
} 