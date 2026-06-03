import logging
import os
from datetime import datetime

import boto3
import pandas as pd
from botocore.exceptions import ClientError, NoCredentialsError
from dotenv import load_dotenv

from extract import fetch_vehicle_positions
from utils import build_time_partitioned_s3_key, convert_to_parquet

load_dotenv()

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

BUCKET_NAME = os.getenv("AWS_BUCKET_NAME")
AWS_ACCESS_KEY_ID = os.getenv("AWS_ACCESS_KEY_ID") or os.getenv("ACCESS_KEY")
AWS_SECRET_ACCESS_KEY = os.getenv("AWS_SECRET_ACCESS_KEY") or os.getenv("SECRET_KEY")
AWS_REGION = os.getenv("AWS_REGION") or os.getenv("AWS_DEFAULT_REGION")

def upload_to_s3(df: pd.DataFrame, s3_key: str) -> bool:

    if not BUCKET_NAME:
        message = "No AWS bucket name specified. Please set the AWS_BUCKET_NAME variable."
        logging.critical(message)
        raise ValueError(message)

    if not AWS_ACCESS_KEY_ID or not AWS_SECRET_ACCESS_KEY:
        message = (
            "No AWS credentials found. Set AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY "
            "or ACCESS_KEY/SECRET_KEY."
        )
        logging.critical(message)
        raise ValueError(message)
    
    parquet_buffer = convert_to_parquet(df)

    client_kwargs = {
        "aws_access_key_id": AWS_ACCESS_KEY_ID,
        "aws_secret_access_key": AWS_SECRET_ACCESS_KEY,
    }

    if AWS_REGION:
        client_kwargs["region_name"] = AWS_REGION

    s3_client = boto3.client('s3', **client_kwargs)
    try:
        s3_client.upload_fileobj(parquet_buffer, BUCKET_NAME, s3_key)
        logging.info(f"File uploaded to S3: {s3_key}")
        return True
    except NoCredentialsError:
        message = "No AWS credentials. Check your configuration."
        logging.error(message)
        raise
    except ClientError as e:
        message = f"Error uploading to S3: {e}"
        logging.error(message)
        raise
