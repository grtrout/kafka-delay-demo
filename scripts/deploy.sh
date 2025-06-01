#!/bin/bash

# Kafka Delay Demo - Automated Deployment Script
# This script deploys the complete infrastructure including automated Flink SQL processing

set -e

echo "🚀 Deploying Kafka Delay Demo with Automated Flink Processing..."
echo

# Check if terraform.tfvars exists
if [ ! -f "terraform/terraform.tfvars" ]; then
    echo "❌ terraform/terraform.tfvars not found!"
    echo "   Please copy terraform/terraform.tfvars.example to terraform/terraform.tfvars"
    echo "   and configure your Confluent Cloud credentials."
    exit 1
fi

# Change to terraform directory
cd terraform

# Initialize Terraform
echo "🔧 Initializing Terraform..."
terraform init

# Validate configuration
echo "✅ Validating Terraform configuration..."
terraform validate

# Plan deployment
echo "📋 Planning deployment..."
terraform plan

# Apply deployment
echo "🏗️  Deploying infrastructure..."
terraform apply -auto-approve

echo
echo "✅ Deployment complete!"
echo
echo "📊 Infrastructure Summary:"
terraform output environment_id | sed 's/^/   Environment: /'
terraform output kafka_cluster_id | sed 's/^/   Kafka Cluster: /'
terraform output flink_compute_pool_id | sed 's/^/   Flink Pool: /'

echo
echo "🤖 Automated Flink SQL Statements:"
terraform output flink_statements | sed 's/^/   /'

echo
echo "🎯 Ready to test!"
echo "   Run: ./scripts/setup-env.sh"
echo "   Then: python apps/producer.py --code TEST --delay 30"
echo "   And: python apps/consumer.py --code TEST" 