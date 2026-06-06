{{ config(materialized='table') }}

SELECT
    vehicle_type,
    
    date_trunc('hour', event_time) AS report_hour,

    COUNT(DISTINCT vehicle_number) AS active_vehicles

FROM {{ ref('stg_transit') }}

GROUP BY
    1, 2