variable "confluent_cloud_api_key" {
  description = "Confluent Cloud API Key (also referred as Cloud API ID)"
  type        = string
  sensitive   = true
  default = ""
}

variable "confluent_cloud_api_secret" {
  description = "Confluent Cloud API Secret"
  type        = string
  sensitive   = true
  default = ""
}

variable "aws_cloud_access_key" {
  description = "AWS Cloud API Key "
  type        = string
  sensitive   = true
  default = ""
}

variable "aws_cloud_secret_key" {
  description = "AWS Secret"
  type        = string
  sensitive   = true
  default = ""
}

variable "destination_s3_bucket" {
  type = string
  default = ""
  
}
