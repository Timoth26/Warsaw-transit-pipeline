from datetime import datetime, timedelta
from enum import IntEnum

import pandas as pd
from airflow.sdk import dag, get_current_context, task

from extract import fetch_vehicle_positions
from load_to_s3 import upload_to_s3
from utils import build_time_partitioned_s3_key

default_args = {
    "owner": "airflow",
    "retries": 2,
    "retry_delay": timedelta(minutes=2),
}


class VehicleType(IntEnum):
    BUS = 1
    TRAM = 2


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
    def extract(vehicle_type: VehicleType):
        return fetch_vehicle_positions(vehicle_type=vehicle_type)

    @task
    def load(data, vehicle_type: VehicleType):
        if not data:
            return "no data"

        df = pd.DataFrame(data)
        context = get_current_context()
        logical_date = context["logical_date"]

        vehicle_name = vehicle_type.name.lower()

        s3_key = build_time_partitioned_s3_key(
            vehicle_name,
            logical_date,
        )

        upload_to_s3(df, s3_key)

        return f"uploaded raw data to {s3_key}"

    buses = extract.override(task_id="extract_buses")(VehicleType.BUS)
    trams = extract.override(task_id="extract_trams")(VehicleType.TRAM)

    load.override(task_id="load_buses")(buses, VehicleType.BUS)
    load.override(task_id="load_trams")(trams, VehicleType.TRAM)


warsaw_transit_el()
