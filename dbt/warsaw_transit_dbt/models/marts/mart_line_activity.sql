{{ config(materialized='table') }}

SELECT
    line_number,
    vehicle_type,

    COUNT(*) AS position_reports,
    COUNT(DISTINCT vehicle_number) AS unique_vehicles

FROM {{ ref('stg_transit') }}

GROUP BY
    line_number,
    vehicle_type