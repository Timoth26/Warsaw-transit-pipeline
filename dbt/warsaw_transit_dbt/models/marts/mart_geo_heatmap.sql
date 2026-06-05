{{ config(materialized='table') }}

WITH hashed AS (
    SELECT
        to_geohash(bing_tile_quadkey(bing_tile_at(lat, lon, 15))) AS full_geohash
    FROM {{ ref('stg_transit') }}
)

SELECT
    SUBSTRING(full_geohash, 1, 7) AS geohash_zone,
    COUNT(*) AS intensity
FROM hashed
GROUP BY
    SUBSTRING(full_geohash, 1, 7)