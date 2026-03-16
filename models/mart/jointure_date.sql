SELECT
  COALESCE(c.date_day, DATE(t.created_at)) AS date_day,
  t.*
FROM {{ ref('stg_raw_data__dim_calendar_') }} c
FULL OUTER JOIN {{ ref('sub_exchanges_adresses_HostisocodeFR') }} t
  ON c.date_day = DATE(t.created_at)
ORDER BY date_day