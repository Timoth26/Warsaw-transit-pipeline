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
    def extract(vehicle_type: int):
        return fetch_vehicle_positions(vehicle_type=vehicle_type)

    @task
    def load(data, vehicle_type: int):
        if not data:
            return "no data"

        df = pd.DataFrame(data)
        context = get_current_context()
        logical_date = context["logical_date"]

        s3_key = build_time_partitioned_s3_key(
            f"{vehicle_type}",
            logical_date,
        )

        upload_to_s3(df, s3_key)

        return f"uploaded raw data to {s3_key}"

    buses = extract.override(task_id="extract_buses")(1)
    trams = extract.override(task_id="extract_trams")(2)

    load.override(task_id="load_buses")(buses, 1)
    load.override(task_id="load_trams")(trams, 2)


warsaw_transit_el()