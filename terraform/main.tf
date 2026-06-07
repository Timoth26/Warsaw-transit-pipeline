terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# --- S3 Bucket ---
resource "aws_s3_bucket" "data_lake" {
  bucket = var.s3_bucket_name

  tags = {
    Name        = "Warsaw Transit Data Lake"
    Environment = "dev"
  }
}

# --- AWS Glue ---
resource "aws_glue_catalog_database" "warsaw_transit" {
  name = "warsaw_transit"
}

resource "aws_iam_role" "glue_role" {
  name = "warsaw-transit-glue-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "glue.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "glue_service_role" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_iam_role_policy" "glue_s3_access" {
  name = "glue-s3-access"
  role = aws_iam_role.glue_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:ListBucket"
      ]
      Resource = [
        aws_s3_bucket.data_lake.arn,
        "${aws_s3_bucket.data_lake.arn}/*"
      ]
    }]
  })
}

# Crawler only for beginning to check structure of raw data
# Do not use Crawler with dbt
resource "aws_glue_crawler" "transit" {
  name          = "warsaw-transit-crawler"
  role          = aws_iam_role.glue_role.arn
  database_name = aws_glue_catalog_database.warsaw_transit.name

  s3_target {
    path = "s3://${aws_s3_bucket.data_lake.bucket}/transit/"
  }

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "LOG"
  }
  
  recrawl_policy {
    recrawl_behavior = "CRAWL_NEW_FOLDERS_ONLY"
  }

  depends_on = [
    aws_iam_role_policy_attachment.glue_service_role,
    aws_iam_role_policy.glue_s3_access
  ]
}