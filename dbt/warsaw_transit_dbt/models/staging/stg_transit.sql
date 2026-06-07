SELECT
    CAST(lat AS DOUBLE) AS lat,
    CAST(lon AS DOUBLE) AS lon,

    CAST(time AS TIMESTAMP) AS event_time,

    lines AS line_number,

    brigade,

    vehiclenumber AS vehicle_number,

    vehicle_type,

    year,
    month,
    day,
    hour

FROM {{ source('glue', 'transit') }}

WHERE lat IS NOT NULL
  AND lon IS NOT NULL