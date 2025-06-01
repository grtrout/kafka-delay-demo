#!/bin/bash

# Environment Setup Script for Kafka Delay Demo
# Sets up Python environment and exports configuration from Terraform

echo "🔧 Setting up environment for Kafka Delay Demo..."

# Create and activate Python virtual environment
if [ ! -d ".venv" ]; then
    echo "🐍 Creating Python virtual environment..."
    python3 -m venv .venv
fi

echo "🐍 Activating virtual environment..."
source .venv/bin/activate

# Install Python dependencies
echo "📦 Installing Python dependencies..."
pip install -r requirements.txt > /dev/null 2>&1

# Check if Terraform has been applied
if ! (cd terraform && terraform output kafka_bootstrap_servers >/dev/null 2>&1); then
    echo "❌ Terraform infrastructure not found."
    echo "   Please run: ./scripts/deploy.sh"
    exit 1
fi

# Extract configuration from Terraform outputs
echo "📡 Getting configuration from Confluent Cloud..."
cd terraform

BOOTSTRAP_SERVERS=$(terraform output -raw kafka_bootstrap_servers)
API_KEY=$(terraform output -raw app_kafka_api_key)
API_SECRET=$(terraform output -raw app_kafka_api_secret)
SCHEMA_REGISTRY_URL=$(terraform output -raw schema_registry_url)
SCHEMA_REGISTRY_KEY=$(terraform output -raw app_schema_registry_api_key)
SCHEMA_REGISTRY_SECRET=$(terraform output -raw app_schema_registry_api_secret)

cd ..

# Export environment variables for the Python applications
export BOOTSTRAP_SERVERS="$BOOTSTRAP_SERVERS"
export API_KEY="$API_KEY"
export API_SECRET="$API_SECRET"
export SCHEMA_REGISTRY_URL="$SCHEMA_REGISTRY_URL"
export SCHEMA_REGISTRY_KEY="$SCHEMA_REGISTRY_KEY"
export SCHEMA_REGISTRY_SECRET="$SCHEMA_REGISTRY_SECRET"

echo "✅ Environment configured successfully!"
echo
echo "📊 Configuration summary:"
echo "   Kafka Cluster: $BOOTSTRAP_SERVERS"
echo "   API Key: $API_KEY"
echo "   Schema Registry: $SCHEMA_REGISTRY_URL"
echo "   Schema Registry Key: $SCHEMA_REGISTRY_KEY"
echo
echo "🎯 Ready to test!"
echo "   Producer: python apps/producer.py --code YOUR_CODE --delay SECONDS"
echo "   Consumer: python apps/consumer.py --code YOUR_CODE"
echo
echo "💡 Note: Flink SQL processing is fully automated - no manual steps required!" 