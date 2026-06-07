{{ config(materialized='table') }}

SELECT
    ROUND(lat, 3) AS lat,
    ROUND(lon, 3) AS lon,
    
    COUNT(*) AS intensity

FROM {{ ref('stg_transit') }}

WHERE lat IS NOT NULL 
  AND lon IS NOT NULL

GROUP BY 
    ROUND(lat, 3),
    ROUND(lon, 3)