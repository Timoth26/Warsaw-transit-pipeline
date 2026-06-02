from datetime import datetime, timedelta

from airflow.sdk import dag, task, get_current_context

import pandas as pd

from load_to_s3 import upload_to_s3
from extract import fetch_vehicle_positions
from utils import build_time_partitioned_s3_key


default_args = {
    "owner": "airflow",
    "retries": 2,
    "retry_delay": timedelta(minutes=2),
}


@dag(
    dag_id="warsaw_transit_dag",
    default_args=default_args,
    start_date=datetime(2024, 1, 1),
    schedule="*/10 * * * *",
    catchup=False,
    tags=["s3", "warsaw_transit"],
)
def warsaw_transit_el():

    @task
    def extract():
        return fetch_vehicle_positions(vehicle_type=1)

    @task
    def load(raw_data):
        if not raw_data:
            return "no data"

        df = pd.DataFrame(raw_data)
        context = get_current_context()
        logical_date = context["logical_date"]

        s3_key = build_time_partitioned_s3_key(
            "buses",
            logical_date,
        )

        upload_to_s3(df, s3_key)

        return f"uploaded raw data to {s3_key}"

    load(
        extract()
    )


warsaw_transit_el()