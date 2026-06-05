{{ config(materialized='table') }}

SELECT
    vehicle_type,
    year,
    month,
    day,
    hour,

    COUNT(*) AS position_reports

FROM {{ ref('stg_transit') }}

GROUP BY
    vehicle_type,
    year,
    month,
    day,
    hour