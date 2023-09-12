output "Environment-id" {
  value = confluent_environment.development.id
}

output "Kafka-Cluster-ID" {
  value = confluent_kafka_cluster.basic.id
}

output "Rekognition-Lambda-Sink-Connector-ID" {
  value = confluent_connector.lambda_sink.id
}

output "Comprehend-Lambda-Sink-Connector-ID" {
  value = confluent_connector.lambda_sink2.id
}
