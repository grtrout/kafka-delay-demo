#!/usr/bin/env python3
"""
Kafka Delay Demo - Message Producer

Sends messages to the 'orders' topic with scheduled processing times.
The automated Flink SQL processing will handle the delay logic.
"""

import click
import os
from datetime import datetime, timedelta
from confluent_kafka import Producer
from confluent_kafka.schema_registry import SchemaRegistryClient
from confluent_kafka.schema_registry.avro import AvroSerializer
from confluent_kafka.serialization import SerializationContext, MessageField

# Avro schema for order messages
# This matches the schema used by the automated Flink SQL tables
ORDER_SCHEMA = """
{
  "type": "record",
  "name": "orders_value",
  "namespace": "org.apache.flink.avro.generated.record",
  "fields": [
    {"name": "code", "type": ["null", "string"], "default": null},
    {"name": "payload", "type": ["null", "string"], "default": null},
    {"name": "scheduled_time", "type": ["null", "string"], "default": null},
    {"name": "created_at", "type": ["null", "string"], "default": null}
  ]
}
"""

def order_to_dict(order, ctx):
    """Convert order object to dictionary for Avro serialization."""
    return order

@click.command()
@click.option('--code', prompt='Message code', help='Unique identifier for this message')
@click.option('--delay', prompt='Delay in seconds', type=int, help='How many seconds to delay processing')
def produce(code, delay):
    """
    Send a message with scheduled processing time.
    
    The message will be processed by automated Flink SQL when the scheduled time arrives.
    """
    
    # Get configuration from environment variables
    bootstrap_servers = os.getenv("BOOTSTRAP_SERVERS")
    api_key = os.getenv("API_KEY")
    api_secret = os.getenv("API_SECRET")
    schema_registry_url = os.getenv("SCHEMA_REGISTRY_URL")
    schema_registry_key = os.getenv("SCHEMA_REGISTRY_KEY")
    schema_registry_secret = os.getenv("SCHEMA_REGISTRY_SECRET")
    
    if not all([bootstrap_servers, api_key, api_secret, schema_registry_url, schema_registry_key, schema_registry_secret]):
        click.echo("❌ Missing required environment variables.")
        click.echo("   Please run: source scripts/setup-env.sh")
        return

    # Configure Schema Registry client
    schema_registry_conf = {
        'url': schema_registry_url,
        'basic.auth.user.info': f'{schema_registry_key}:{schema_registry_secret}'
    }
    schema_registry_client = SchemaRegistryClient(schema_registry_conf)
    
    # Create Avro serializer
    avro_serializer = AvroSerializer(
        schema_registry_client,
        ORDER_SCHEMA,
        order_to_dict
    )
    
    # Configure Kafka producer
    producer_conf = {
        'bootstrap.servers': bootstrap_servers,
        'security.protocol': 'SASL_SSL',
        'sasl.mechanism': 'PLAIN',
        'sasl.username': api_key,
        'sasl.password': api_secret,
        'acks': 'all',
        'retries': 3,
        'compression.type': 'snappy'
    }
    
    producer = Producer(producer_conf)
    
    # Create the message
    now = datetime.utcnow()
    scheduled_time = now + timedelta(seconds=delay)
    
    order = {
        'code': str(code),
        'payload': f'Delayed message for {code}',
        'scheduled_time': scheduled_time.strftime('%Y-%m-%d %H:%M:%S'),
        'created_at': now.strftime('%Y-%m-%d %H:%M:%S')
    }
    
    try:
        # Serialize and send the message
        serialized_value = avro_serializer(
            order, 
            SerializationContext('orders', MessageField.VALUE)
        )
        
        producer.produce(
            topic='orders',
            key=str(code),
            value=serialized_value
        )
        
        producer.flush()
        
        click.echo(f"✅ Message sent successfully!")
        click.echo(f"   Code: {code}")
        click.echo(f"   Sent at: {now.strftime('%H:%M:%S')} UTC")
        click.echo(f"   Will be processed at: {scheduled_time.strftime('%H:%M:%S')} UTC")
        click.echo(f"   Delay: {delay} seconds")
        click.echo()
        click.echo("🤖 Automated Flink SQL will process this message when the time arrives.")
        
    except Exception as e:
        click.echo(f"❌ Error sending message: {e}")

if __name__ == '__main__':
    produce() 