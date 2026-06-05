{{ config(materialized='table') }}

SELECT
    line_number,
    vehicle_type,
    COUNT(*) AS observations
FROM {{ ref('stg_transit') }}
GROUP BY 1,2
ORDER BY observations DESC