{{ config(materialized='table') }}

SELECT
    vehicle_id,
    vehicle_type,
    -- Dla każdego pojazdu zbieramy współrzędne w chronologiczną tablicę [lon, lat]
    -- Uwaga: W dbt-athena/Presto czasami współrzędne dla deck.gl buduje się jako JSON lub tablicę obiektów
    array_agg(array[lon, lat] ORDER BY event_time) AS path_coordinates

FROM {{ ref('stg_transit') }}
WHERE lat IS NOT NULL AND lon IS NOT NULL
GROUP BY
    1, 2