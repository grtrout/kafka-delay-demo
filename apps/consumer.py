#!/usr/bin/env python3
"""
Kafka Delay Demo - Message Consumer

Consumes processed messages from the 'processed_orders' topic.
These messages have been automatically processed by Flink SQL when their scheduled time arrived.
"""

import click
import os
import json
from confluent_kafka import Consumer, KafkaError
from confluent_kafka.schema_registry import SchemaRegistryClient
from confluent_kafka.schema_registry.avro import AvroDeserializer
from confluent_kafka.serialization import SerializationContext, MessageField

# Avro schema for processed order messages
# This matches the schema used by the automated Flink SQL tables
PROCESSED_ORDER_SCHEMA = """
{
  "type": "record",
  "name": "processed_orders_value",
  "namespace": "org.apache.flink.avro.generated.record",
  "fields": [
    {"name": "code", "type": ["null", "string"], "default": null},
    {"name": "payload", "type": ["null", "string"], "default": null},
    {"name": "scheduled_time", "type": ["null", "string"], "default": null},
    {"name": "created_at", "type": ["null", "string"], "default": null},
    {"name": "processed_time", "type": ["null", "long"], "default": null}
  ]
}
"""

def dict_to_order(obj, ctx):
    """Convert dictionary to order object for Avro deserialization."""
    if obj is None:
        return None
    return obj

@click.command()
@click.option('--code', help='Filter messages by code (optional)')
@click.option('--timeout', default=30, help='Timeout in seconds (default: 30)')
def consume(code, timeout):
    """
    Consume processed messages from the delay processing system.
    
    Messages are automatically processed by Flink SQL when their scheduled time arrives.
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
    
    # Create Avro deserializer
    avro_deserializer = AvroDeserializer(
        schema_registry_client,
        PROCESSED_ORDER_SCHEMA,
        dict_to_order
    )
    
    # Configure Kafka consumer
    consumer_conf = {
        'bootstrap.servers': bootstrap_servers,
        'security.protocol': 'SASL_SSL',
        'sasl.mechanism': 'PLAIN',
        'sasl.username': api_key,
        'sasl.password': api_secret,
        'group.id': f'delay-demo-consumer-{code}' if code else 'delay-demo-consumer',
        'auto.offset.reset': 'earliest',
        'enable.auto.commit': True
    }
    
    consumer = Consumer(consumer_conf)
    consumer.subscribe(['processed_orders'])
    
    if code:
        click.echo(f"🔍 Waiting for processed messages with code '{code}'...")
    else:
        click.echo("🔍 Waiting for all processed messages...")
    
    click.echo("   Press Ctrl+C to exit")
    click.echo()
    
    try:
        message_count = 0
        while True:
            msg = consumer.poll(timeout=1.0)
            
            if msg is None:
                continue
                
            if msg.error():
                if msg.error().code() == KafkaError._PARTITION_EOF:
                    continue
                else:
                    click.echo(f"❌ Consumer error: {msg.error()}")
                    break
            
            try:
                # Deserialize the message
                order = avro_deserializer(
                    msg.value(),
                    SerializationContext('processed_orders', MessageField.VALUE)
                )
                
                if order is None:
                    continue
                
                # Filter by code if specified
                if code and order.get('code') != code:
                    continue
                
                message_count += 1
                
                # Display the processed message
                click.echo(f"📨 Processed Message #{message_count}")
                click.echo(f"   Code: {order.get('code', 'N/A')}")
                click.echo(f"   Payload: {order.get('payload', 'N/A')}")
                click.echo(f"   Originally scheduled: {order.get('scheduled_time', 'N/A')}")
                click.echo(f"   Created: {order.get('created_at', 'N/A')}")
                
                if order.get('processed_time'):
                    from datetime import datetime
                    processed_dt = datetime.fromtimestamp(order['processed_time'] / 1000)
                    click.echo(f"   Processed: {processed_dt.strftime('%Y-%m-%d %H:%M:%S')} UTC")
                
                click.echo("   🤖 Automatically processed by Flink SQL")
                click.echo()
                
            except Exception as e:
                click.echo(f"❌ Error deserializing message: {e}")
                
    except KeyboardInterrupt:
        click.echo()
        click.echo(f"✅ Consumed {message_count} messages. Goodbye!")
        
    finally:
        consumer.close()

if __name__ == '__main__':
    consume() 