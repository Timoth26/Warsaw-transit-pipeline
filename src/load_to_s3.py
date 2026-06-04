import logging
import os

import boto3
import pandas as pd
from botocore.exceptions import ClientError, NoCredentialsError
from dotenv import load_dotenv

from utils import convert_to_parquet

load_dotenv()

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s"
)

BUCKET_NAME = os.getenv("AWS_BUCKET_NAME")
AWS_REGION = os.getenv("AWS_REGION") or os.getenv("AWS_DEFAULT_REGION")


def upload_to_s3(df: pd.DataFrame, s3_key: str) -> bool:

    if not BUCKET_NAME:
        message = (
            "No AWS bucket name specified. Please set the AWS_BUCKET_NAME variable."
        )
        raise ValueError(message)

    parquet_buffer = convert_to_parquet(df)

    session_kwargs = {}

    if AWS_REGION:
        session_kwargs["region_name"] = AWS_REGION

    s3_client = boto3.client("s3", **session_kwargs)

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
