# Service account for CLI applications (producer and consumer)
resource "confluent_service_account" "app" {
  display_name = "${var.project_name}-app"
  description  = "Service account for producer and consumer applications"
}

# Service account for Flink SQL processing
resource "confluent_service_account" "flink" {
  display_name = "${var.project_name}-flink"
  description  = "Service account for automated Flink SQL processing"
}

# Role bindings for application service account
resource "confluent_role_binding" "app_environment_admin" {
  principal   = "User:${confluent_service_account.app.id}"
  role_name   = "EnvironmentAdmin"
  crn_pattern = confluent_environment.main.resource_name
}

resource "confluent_role_binding" "app_cluster_admin" {
  principal   = "User:${confluent_service_account.app.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.main.rbac_crn
}

# Role bindings for Flink service account
resource "confluent_role_binding" "flink_environment_admin" {
  principal   = "User:${confluent_service_account.flink.id}"
  role_name   = "EnvironmentAdmin"
  crn_pattern = confluent_environment.main.resource_name
}

resource "confluent_role_binding" "flink_cluster_admin" {
  principal   = "User:${confluent_service_account.flink.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.main.rbac_crn
} 