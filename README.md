# Kafka Delay Demo with Automated Flink Processing

![Flink Delivery Squirrel](docs/images/flink_delivery_squirrel.jpg)

A demonstration of delayed message processing using Confluent Cloud Kafka and fully automated Flink SQL. Messages are sent with scheduled processing times and automatically handled when their time arrives - no manual intervention required.

## 🚀 Features

- **Fully Automated**: Complete infrastructure deployment with Terraform
- **Zero Manual Steps**: Flink SQL statements are deployed automatically
- **Production Ready**: Proper service accounts, API keys, and RBAC
- **Clean Architecture**: Organized codebase with logical separation
- **Real-time Processing**: Messages processed exactly when scheduled
- **Configurable**: Easy customization of regions, names, and resource sizes

## 🏗️ Architecture

```
Producer → [orders topic] → Flink SQL → [processed_orders topic] → Consumer
                              ↓
                        Automated delay logic
                     (processes when time arrives)
```

### Components

- **Kafka Cluster**: Message storage and streaming
- **Schema Registry**: Avro schema management
- **Flink SQL**: Automated delay processing logic
- **Python Apps**: Producer and consumer applications

## 📁 Project Structure

```
kafka-delay-demo/
├── terraform/              # Infrastructure as Code
│   ├── providers.tf        # Terraform and provider configuration
│   ├── variables.tf        # Input variables with defaults
│   ├── environment.tf      # Confluent Cloud environment
│   ├── kafka.tf           # Kafka cluster configuration
│   ├── flink.tf           # Flink compute pool and SQL automation
│   ├── service_accounts.tf # Service accounts and RBAC
│   ├── api_keys.tf        # API key management
│   ├── outputs.tf         # Output values
│   ├── terraform.tfvars   # Your credentials (not in git)
│   └── terraform.tfvars.example
├── apps/                   # Python applications
│   ├── producer.py        # Send delayed messages
│   └── consumer.py        # Receive processed messages
├── scripts/               # Automation scripts
│   ├── deploy.sh         # Deploy infrastructure
│   ├── setup-env.sh      # Configure environment
│   └── destroy.sh        # Clean teardown
├── requirements.txt       # Python dependencies
└── README.md
```

## 🚀 Quick Start

### 1. Prerequisites

- [Terraform](https://terraform.io) >= 1.0
- Python 3.8+
- Confluent Cloud account with API keys

### 2. Configure Credentials

```bash
# Copy the example configuration
cp terraform/terraform.tfvars.example terraform/terraform.tfvars

# Edit with your Confluent Cloud credentials
# Get these from: https://confluent.cloud/settings/api-keys
vim terraform/terraform.tfvars
```

### 3. Customize Configuration (Optional)

The `terraform.tfvars` file supports several configuration options:

```hcl
# Required: Your Confluent Cloud credentials
ccloud_api_key    = "your-api-key-here"
ccloud_api_secret = "your-api-secret-here"

# Optional: Project configuration
project_name = "my-delay-demo"           # Default: "kafka-delay-demo"

# Optional: Infrastructure settings
region = "us-west-2"                     # Default: "us-east-1"
cloud_provider = "AWS"                   # Default: "AWS"
kafka_availability = "MULTI_ZONE"       # Default: "SINGLE_ZONE"

# Optional: Flink settings
flink_max_cfu = 10                       # Default: 5
```

### 4. Deploy Infrastructure

```bash
# Deploy everything (infrastructure + automated Flink SQL)
./scripts/deploy.sh
```

This single command:
- Creates Confluent Cloud environment with Schema Registry
- Deploys Kafka cluster and Flink compute pool
- Sets up service accounts and API keys
- **Automatically deploys all Flink SQL statements**
- No manual steps required!

### 5. Set Up Environment

```bash
# Configure Python environment and export credentials
source scripts/setup-env.sh
```

### 6. Test the System

```bash
# Send a message with 30-second delay
python apps/producer.py --code TEST123 --delay 30

# In another terminal, watch for processed messages
python apps/consumer.py --code TEST123
```

## 🔧 How It Works

### Automated Flink SQL Processing

The system automatically deploys three Flink SQL statements:

1. **Orders Table**: Receives incoming messages
```sql
CREATE TABLE orders (
  code STRING,
  payload STRING,
  scheduled_time STRING,
  created_at STRING
) WITH (
  'connector' = 'confluent',
  'value.format' = 'avro-registry'
)
```

2. **Processed Orders Table**: Stores processed messages
```sql
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
```

3. **Delay Processor**: Automatically processes messages when time arrives
```sql
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
```

### Message Flow

1. **Producer** sends message with `scheduled_time`
2. **Flink SQL** continuously monitors the `orders` topic
3. When `scheduled_time` arrives, message is automatically processed
4. Processed message appears in `processed_orders` topic
5. **Consumer** receives the processed message

## 🛠️ Development

### Running Individual Components

```bash
# Deploy only infrastructure
cd terraform && terraform apply

# Set up environment
source scripts/setup-env.sh

# Send test message
python apps/producer.py --code DEV001 --delay 60

# Consume all messages (no filtering)
python apps/consumer.py

# Consume with timeout
python apps/consumer.py --timeout 60
```

### Monitoring

Check Flink SQL processing in Confluent Cloud:
1. Go to your environment
2. Navigate to Flink → Compute Pools
3. View running SQL statements

## 🧹 Cleanup

```bash
# Destroy all resources
./scripts/destroy.sh
```

## 🔒 Security

- Service accounts with minimal required permissions
- Separate API keys for Kafka and Schema Registry
- Sensitive values marked as sensitive in Terraform
- Credentials never committed to git

## 📊 Use Cases

- **Order Processing**: Delay order fulfillment until specific times
- **Scheduled Notifications**: Send reminders or alerts at precise moments
- **Rate Limiting**: Control processing rates by scheduling message releases
- **Batch Processing**: Collect messages and process them in scheduled batches
- **Workflow Orchestration**: Coordinate multi-step processes with timing

