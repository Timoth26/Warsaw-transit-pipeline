import os
import io
import logging
from datetime import datetime
import pandas as pd
import boto3
from botocore.exceptions import NoCredentialsError, ClientError
from dotenv import load_dotenv
from extract import fetch_vehicle_positions
from utils import convert_to_parquet


load_dotenv()

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

BUCKET_NAME = os.getenv("AWS_BUCKET_NAME")

def upload_to_s3(df: pd.DataFrame, s3_key: str) -> bool:

    if not BUCKET_NAME:
        logging.critical("No AWS bucket name specified. Please set the BUCKET_NAME variable.")
        return False
    
    parquet_buffer = convert_to_parquet(df)

    s3_client = boto3.client('s3')
    try:
        s3_client.upload_fileobj(parquet_buffer, BUCKET_NAME, s3_key)
        logging.info(f"File uploaded to S3: {s3_key}")
        return True
    except NoCredentialsError:
        logging.error("No AWS credentials. Check your configuration.")
        return False
    except ClientError as e:
        logging.error(f"Error uploading to S3: {e}")
        return False
