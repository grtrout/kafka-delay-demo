#!/bin/bash

# Kafka Delay Demo - Infrastructure Teardown Script
# Safely destroys all Confluent Cloud resources

set -e

echo "🗑️  Destroying Kafka Delay Demo infrastructure..."
echo

# Confirm destruction
read -p "Are you sure you want to destroy all resources? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "❌ Destruction cancelled."
    exit 1
fi

# Change to terraform directory
cd terraform

# Destroy infrastructure
echo "🏗️  Destroying infrastructure..."
terraform destroy -auto-approve

echo
echo "✅ Infrastructure destroyed successfully!"
echo "   All Confluent Cloud resources have been removed." 