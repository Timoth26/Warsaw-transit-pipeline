variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "eu-central-1"
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket for the data lake"
  type        = string
  default     = "warsaw-transit-data-lake-90123"
}

variable "allowed_ip" {
  description = "Local IP address allowed to connect via SSH and access Airflow UI (without /32)"
  type        = string
  default     = "77.236.0.96"
}

variable "key_name" {
  description = "The name of the AWS SSH key pair"
  type        = string
  default     = "ec2-warsaw-transit"
}