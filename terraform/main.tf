#This part creates environment
resource "confluent_environment" "development" {
  display_name = "background-check"
  }

data "confluent_schema_registry_region" "example" {
  cloud   = "AWS"
  region  = "ap-southeast-2"
  package = "ESSENTIALS"
}

resource "confluent_schema_registry_cluster" "essentials" {
  package = data.confluent_schema_registry_region.example.package
  
  environment {
    id = confluent_environment.development.id
  }

  region {
    id = data.confluent_schema_registry_region.example.id
  }
}

#This part creates cluster inside environment
resource "confluent_kafka_cluster" "basic" {
  display_name = "cluster1"
  availability = "SINGLE_ZONE"
  cloud        = "AWS"
  region       = "ap-south-1"
  basic {}

  environment {
    id= confluent_environment.development.id
  }
  }

resource "confluent_service_account" "app-manager2" {
  display_name = "app-manager2"
  description  = "Service account to manage 'inventory' Kafka cluster"
}

resource "confluent_role_binding" "app-manager2-kafka-cluster-admin" {
  principal   = "User:${confluent_service_account.app-manager2.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.basic.rbac_crn
}

resource "confluent_api_key" "app-manager2-kafka-api-key" {
  display_name = "app-manager2-kafka-api-key"
  description  = "Kafka API Key that is owned by 'app-manager2' service account"

  owner {
    id          = confluent_service_account.app-manager2.id
    api_version = confluent_service_account.app-manager2.api_version
    kind        = confluent_service_account.app-manager2.kind
  }
  managed_resource {
    id          = confluent_kafka_cluster.basic.id
    api_version = confluent_kafka_cluster.basic.api_version
    kind        = confluent_kafka_cluster.basic.kind

    environment {
      id = confluent_environment.development.id
    }
  }
  depends_on = [
    confluent_role_binding.app-manager2-kafka-cluster-admin
  ]
}

# This part creates a topics 

resource "confluent_kafka_topic" "user_basic_info" {
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }
  topic_name    = "user_basic_info"
  rest_endpoint = confluent_kafka_cluster.basic.rest_endpoint
  partitions_count = 1
  credentials {
    key   = confluent_api_key.app-manager2-kafka-api-key.id
    secret = confluent_api_key.app-manager2-kafka-api-key.secret
  }
}

resource "confluent_kafka_topic" "user_posts_description" {
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }
  topic_name    = "user_posts_description"
  partitions_count = 1
  rest_endpoint = confluent_kafka_cluster.basic.rest_endpoint
  credentials {
    key   = confluent_api_key.app-manager2-kafka-api-key.id
    secret = confluent_api_key.app-manager2-kafka-api-key.secret
  }
}

resource "confluent_kafka_topic" "user_posts_images" {
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }
  topic_name    = "user_posts_images"
  partitions_count = 1
  rest_endpoint = confluent_kafka_cluster.basic.rest_endpoint
  credentials {
    key   = confluent_api_key.app-manager2-kafka-api-key.id
    secret = confluent_api_key.app-manager2-kafka-api-key.secret
  }
}

resource "confluent_kafka_topic" "joined_topic" {
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }
  topic_name    = "joined_topic"
  rest_endpoint = confluent_kafka_cluster.basic.rest_endpoint
  partitions_count = 1
  credentials {
    key   = confluent_api_key.app-manager2-kafka-api-key.id
    secret = confluent_api_key.app-manager2-kafka-api-key.secret
  }
}

resource "confluent_kafka_topic" "final_topic" {
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }
  topic_name    = "final_topic"
  rest_endpoint = confluent_kafka_cluster.basic.rest_endpoint
  partitions_count = 1
  credentials {
    key   = confluent_api_key.app-manager2-kafka-api-key.id
    secret = confluent_api_key.app-manager2-kafka-api-key.secret
  }
}

resource "confluent_ksql_cluster" "ksqldb" {
  display_name = "ksqldb-cluster"
  csu          = 1

  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }
  credential_identity {
    id = confluent_service_account.app-manager2.id
  }
  environment {
    id = confluent_environment.development.id
     
  }
  depends_on = [
    confluent_role_binding.app-manager2-kafka-cluster-admin,
    confluent_schema_registry_cluster.essentials
  ]
}