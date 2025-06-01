# Kafka cluster for message storage and streaming
resource "confluent_kafka_cluster" "main" {
  display_name = var.project_name
  availability = var.kafka_availability
  cloud        = var.cloud_provider
  region       = var.region

  environment {
    id = confluent_environment.main.id
  }

  standard {}
} 