# Flink compute pool for stream processing
resource "confluent_flink_compute_pool" "main" {
  display_name = "${var.project_name}-flink"
  cloud        = var.cloud_provider
  region       = var.region
  max_cfu      = var.flink_max_cfu

  environment {
    id = confluent_environment.main.id
  }
}

# Data sources for Flink automation
data "confluent_flink_region" "main" {
  cloud  = var.cloud_provider
  region = var.region
}

data "confluent_organization" "main" {}

# Automated Flink SQL Statements
# These replace the manual SQL execution step

# Create the orders table for incoming messages
resource "confluent_flink_statement" "orders_table" {
  organization {
    id = data.confluent_organization.main.id
  }
  
  environment {
    id = confluent_environment.main.id
  }
  
  compute_pool {
    id = confluent_flink_compute_pool.main.id
  }
  
  principal {
    id = confluent_service_account.flink.id
  }
  
  statement = <<EOT
CREATE TABLE orders (
  code STRING,
  payload STRING,
  scheduled_time STRING,
  created_at STRING
) WITH (
  'connector' = 'confluent',
  'value.format' = 'avro-registry'
)
EOT

  properties = {
    "sql.current-catalog"  = confluent_environment.main.display_name
    "sql.current-database" = confluent_kafka_cluster.main.display_name
  }

  rest_endpoint = data.confluent_flink_region.main.rest_endpoint
  
  credentials {
    key    = confluent_api_key.flink.id
    secret = confluent_api_key.flink.secret
  }

  depends_on = [
    confluent_flink_compute_pool.main,
    confluent_api_key.flink,
    confluent_kafka_cluster.main
  ]
}

# Create the processed orders table for delayed messages
resource "confluent_flink_statement" "processed_orders_table" {
  organization {
    id = data.confluent_organization.main.id
  }
  
  environment {
    id = confluent_environment.main.id
  }
  
  compute_pool {
    id = confluent_flink_compute_pool.main.id
  }
  
  principal {
    id = confluent_service_account.flink.id
  }
  
  statement = <<EOT
CREATE TABLE processed_orders (
  code STRING,
  payload STRING,
  scheduled_time STRING,
  created_at STRING,
  processed_time BIGINT
) WITH (
  'connector' = 'confluent',
  'value.format' = 'avro-registry'
)
EOT

  properties = {
    "sql.current-catalog"  = confluent_environment.main.display_name
    "sql.current-database" = confluent_kafka_cluster.main.display_name
  }

  rest_endpoint = data.confluent_flink_region.main.rest_endpoint
  
  credentials {
    key    = confluent_api_key.flink.id
    secret = confluent_api_key.flink.secret
  }

  depends_on = [
    confluent_flink_statement.orders_table
  ]
}

# The delay processing logic - processes messages when their time arrives
resource "confluent_flink_statement" "delay_processor" {
  organization {
    id = data.confluent_organization.main.id
  }
  
  environment {
    id = confluent_environment.main.id
  }
  
  compute_pool {
    id = confluent_flink_compute_pool.main.id
  }
  
  principal {
    id = confluent_service_account.flink.id
  }
  
  statement = <<EOT
INSERT INTO processed_orders
SELECT 
  code,
  payload,
  scheduled_time,
  created_at,
  UNIX_TIMESTAMP() * 1000 as processed_time
FROM orders
WHERE 
  UNIX_TIMESTAMP(scheduled_time, 'yyyy-MM-dd HH:mm:ss') * 1000 <= UNIX_TIMESTAMP() * 1000
EOT

  properties = {
    "sql.current-catalog"  = confluent_environment.main.display_name
    "sql.current-database" = confluent_kafka_cluster.main.display_name
  }

  rest_endpoint = data.confluent_flink_region.main.rest_endpoint
  
  credentials {
    key    = confluent_api_key.flink.id
    secret = confluent_api_key.flink.secret
  }

  depends_on = [
    confluent_flink_statement.processed_orders_table
  ]
} 