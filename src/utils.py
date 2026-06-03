import io
from datetime import datetime


def convert_to_parquet(df):
    parquet_buffer = io.BytesIO()
    df.to_parquet(parquet_buffer, engine='pyarrow', compression='snappy', index=False)
    parquet_buffer.seek(0)
    return parquet_buffer


def build_time_partitioned_s3_key(vehicle_type: str, now: datetime | None = None) -> str:
    now = now or datetime.now()

    return (
        f"{vehicle_type}/raw/year={now.year}/month={now.month:02d}/"
        f"day={now.day:02d}/hour={now.hour:02d}/"
        f"{now.strftime('%Y%m%d_%H%M%S')}.parquet"
    )