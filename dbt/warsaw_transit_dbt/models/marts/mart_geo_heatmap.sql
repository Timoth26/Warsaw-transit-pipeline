{{ config(materialized='table') }}

SELECT
    lat,
    lon,

    COUNT(*) AS intensity

FROM {{ ref('stg_transit') }}

GROUP BY
    lat,
    lon