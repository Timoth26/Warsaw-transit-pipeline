{{ config(materialized='table') }}

SELECT
    vehicle_number,
    vehicle_type,
    -- Dla każdego pojazdu zbieramy współrzędne w chronologiczną tablicę [lon, lat]
    -- Uwaga: W dbt-athena/Presto czasami współrzędne dla deck.gl buduje się jako JSON lub tablicę obiektów
    array_agg(array[lon, lat] ORDER BY event_time) AS path_coordinates,
    MIN(event_time) AS route_start_time,
    MAX(event_time) AS route_end_time

FROM {{ ref('stg_transit') }}
WHERE lat IS NOT NULL AND lon IS NOT NULL
GROUP BY
    1, 2