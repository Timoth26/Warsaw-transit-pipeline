import logging
import os

import requests
from dotenv import load_dotenv

load_dotenv()

logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

API_KEY = os.getenv("API_KEY")
URL = os.getenv("URL")


def fetch_vehicle_positions(vehicle_type=2):

    if not API_KEY:
        logging.critical("API key is not set. Please set the API_KEY variable.")
        raise ValueError("API key is required to fetch vehicle positions.")

    headers = {
        "Authorization": API_KEY,
        "Content-Type": "application/json",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko)"
        " Chrome/120.0.0.0 Safari/537.36",
    }

    payload = {"type": vehicle_type}

    try:
        logging.info(f"Request sent to {URL} with payload: {payload}")

        response = requests.post(URL, headers=headers, json=payload, timeout=30)

        response.raise_for_status()

        return response.json()

    except requests.exceptions.RequestException as e:
        logging.error(f"Request failed: {e}")
        raise


if __name__ == "__main__":
    # For testing purposes, we can run the extraction function directly
    logging.info("Starting data extraction...")
    vehicle_data = fetch_vehicle_positions()

    if vehicle_data:
        logging.info(f"Successfully fetched {len(vehicle_data)} vehicle positions.")
        print(vehicle_data[1:10])
