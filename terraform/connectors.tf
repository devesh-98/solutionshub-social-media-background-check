
### Lambda Sink Rekognition ###

resource "confluent_connector" "lambda_sink" {
  environment {
    id = confluent_environment.development.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }
  config_sensitive = {
    "aws.access.key.id"     = var.aws_cloud_access_key
    "aws.secret.access.key" = var.aws_cloud_secret_key
  }
  config_nonsensitive = {
    "topics"                   = confluent_kafka_topic.user_posts_images.topic_name
    "input.data.format"        = "JSON"
    "connector.class"          = "LambdaSink"
    "name"                     = "Rekognition_Lambda_sink"
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.app-manager2.id
    "tasks.max"                = "1"
    "aws.lambda.configuration.mode" = "single"
    "aws.lambda.function.name"      = aws_lambda_function.rekognition_lambda.function_name
    "aws.lambda.invocation.type" = "sync"
    "behavior.on.error"          = "log"
    "transforms"              = "ValueToKey"
    "transforms.ValueToKey.type"  = "org.apache.kafka.connect.transforms.ValueToKey"
    "transforms.ValueToKey.fields"=  "s3_path"

  }
}

### Lambda Sink Comprehend ###

resource "confluent_connector" "lambda_sink2" {
  environment {
    id = confluent_environment.development.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }

  config_sensitive = {
    "aws.access.key.id"     = var.aws_cloud_access_key
    "aws.secret.access.key" = var.aws_cloud_secret_key
  }

  config_nonsensitive = {
    "topics"                   = confluent_kafka_topic.user_posts_description.topic_name
    "input.data.format"        = "JSON"
    "connector.class"          = "LambdaSink"
    "name"                     = "Comprehend_Lambda_sink"
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.app-manager2.id
    "tasks.max"                = "1"
    "aws.lambda.configuration.mode" = "single"
    "aws.lambda.function.name"      = aws_lambda_function.comprehend_lambda.function_name
    "aws.lambda.invocation.type" = "sync"
    "behavior.on.error"          = "log"
    "transforms"                    =  "transform_0,transform_1"
    "transforms.transform_0.type"   = "org.apache.kafka.connect.transforms.ValueToKey"
    "transforms.transform_0.fields" = "username"
    "transforms.transform_1.type"   =  "org.apache.kafka.connect.transforms.ExtractField$Key"
    "transforms.transform_1.field"  =  "username"
  }
}

### Lambda Sink Final ###

resource "confluent_connector" "lambda_sink3" {
  environment {
    id = confluent_environment.development.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }
  config_sensitive = {
    "aws.access.key.id"     = var.aws_cloud_access_key
    "aws.secret.access.key" = var.aws_cloud_secret_key
  }

  config_nonsensitive = {
    "topics"                   = confluent_kafka_topic.final_topic.topic_name
    "input.data.format"        = "JSON"
    "connector.class"          = "LambdaSink"
    "name"                     = "Final_Lambda_sink"
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.app-manager2.id
    "tasks.max"                = "1"
    "aws.lambda.configuration.mode" = "single"
    "aws.lambda.function.name"      = aws_lambda_function.final_lambda.function_name
    "aws.lambda.invocation.type" = "sync"
     "behavior.on.error"          = "log"
  }
}

### S3 Sink ###
resource "confluent_connector" "s3_sink" {
  environment {
    id = confluent_environment.development.id
  }
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }

  config_sensitive = {
    "aws.access.key.id"     = var.aws_cloud_access_key
    "aws.secret.access.key" = var.aws_cloud_secret_key
  }

  config_nonsensitive = {
    "topics"                   = format("success-%s",confluent_connector.lambda_sink3.id)
    "input.data.format"        = "JSON"
    "connector.class"          = "S3_SINK"
    "name"                     = "S3_SINKConnector_0"
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.app-manager2.id
    "s3.bucket.name"           = aws_s3_bucket.final_bucket.bucket
    "output.data.format"       = "JSON"
    "time.interval"            = "HOURLY"
    "flush.size"               = "1000"
    "tasks.max"                = "1"
  }
  depends_on = [ confluent_connector.lambda_sink3 ]
}
