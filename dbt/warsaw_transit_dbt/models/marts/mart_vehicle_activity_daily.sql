{{ config(materialized='table') }}

SELECT
    vehicle_type,

    year,
    month,
    day,

    COUNT(*) AS position_reports,

    COUNT(DISTINCT vehicle_number) AS active_vehicles

FROM {{ ref('stg_transit') }}

GROUP BY
    vehicle_type,
    year,
    month,
    day