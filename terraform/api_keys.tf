# Kafka API key for application service account
resource "confluent_api_key" "app_kafka" {
  display_name = "${var.project_name}-app-kafka"
  description  = "Kafka API Key for producer and consumer applications"
  
  owner {
    id          = confluent_service_account.app.id
    api_version = confluent_service_account.app.api_version
    kind        = confluent_service_account.app.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.main.id
    api_version = confluent_kafka_cluster.main.api_version
    kind        = confluent_kafka_cluster.main.kind

    environment {
      id = confluent_environment.main.id
    }
  }
}

# Schema Registry API key for application service account
resource "confluent_api_key" "app_schema_registry" {
  display_name = "${var.project_name}-app-sr"
  description  = "Schema Registry API Key for producer and consumer applications"
  
  owner {
    id          = confluent_service_account.app.id
    api_version = confluent_service_account.app.api_version
    kind        = confluent_service_account.app.kind
  }

  managed_resource {
    id          = data.confluent_schema_registry_cluster.main.id
    api_version = data.confluent_schema_registry_cluster.main.api_version
    kind        = data.confluent_schema_registry_cluster.main.kind

    environment {
      id = confluent_environment.main.id
    }
  }
}

# Flink API key for automated SQL statements
resource "confluent_api_key" "flink" {
  display_name = "${var.project_name}-flink"
  description  = "Flink API Key for automated SQL statements"
  
  owner {
    id          = confluent_service_account.flink.id
    api_version = confluent_service_account.flink.api_version
    kind        = confluent_service_account.flink.kind
  }

  managed_resource {
    id          = data.confluent_flink_region.main.id
    api_version = data.confluent_flink_region.main.api_version
    kind        = data.confluent_flink_region.main.kind

    environment {
      id = confluent_environment.main.id
    }
  }

  depends_on = [
    confluent_service_account.flink,
    confluent_role_binding.flink_environment_admin,
    confluent_role_binding.flink_cluster_admin
  ]
}

# Schema Registry API key for Flink service account
resource "confluent_api_key" "flink_schema_registry" {
  display_name = "${var.project_name}-flink-sr"
  description  = "Schema Registry API Key for Flink SQL processing"
  
  owner {
    id          = confluent_service_account.flink.id
    api_version = confluent_service_account.flink.api_version
    kind        = confluent_service_account.flink.kind
  }

  managed_resource {
    id          = data.confluent_schema_registry_cluster.main.id
    api_version = data.confluent_schema_registry_cluster.main.api_version
    kind        = data.confluent_schema_registry_cluster.main.kind

    environment {
      id = confluent_environment.main.id
    }
  }
} 