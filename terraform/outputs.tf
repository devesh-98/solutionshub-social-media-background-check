output "resource-ids" {
  value = <<-EOT
  Environment ID:                       ${confluent_environment.development.id}
  Kafka Cluster ID:                     ${confluent_kafka_cluster.basic.id}
  ksqlDB Cluster ID:                    ${confluent_ksql_cluster.ksqldb.id}

  Service Accounts and their Kafka API Keys (API Keys inherit the permissions granted to the owner):
${confluent_service_account.app-manager2.display_name}:                     ${confluent_service_account.app-manager2.id}
${confluent_service_account.app-manager2.display_name}'s Kafka API Key:     "${confluent_api_key.app-manager2-kafka-api-key.id}"
${confluent_service_account.app-manager2.display_name}'s Kafka API Secret:  "${confluent_api_key.app-manager2-kafka-api-key.secret}"

  EOT
  sensitive = true
}
