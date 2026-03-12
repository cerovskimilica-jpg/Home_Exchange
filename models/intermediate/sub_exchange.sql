WITH pro AS (
  SELECT
    s.* EXCEPT(country, region, city, department),
    e.* EXCEPT(country, region, city, department),

    -- host
    s.country AS country_exc,
    e.country AS country_sub,
    s.region AS region_exc,
    e.region AS region_sub,
    s.city AS city_exc,
    e.city AS city_sub,
    s.department AS department_exc,
    e.department AS department_sub,

    -- guest : on prend seulement les colonnes utiles
    sguest.country AS country_guest,
    sguest.region AS region_guest,
    sguest.city AS city_guest,
    sguest.department AS department_guest

  FROM {{ ref('stg_raw_data__exchanges') }} AS s
  LEFT JOIN {{ ref('sub_no_duplicates') }} AS e
    ON e.user_id = s.host_user_id
  LEFT JOIN {{ ref('sub_no_duplicates') }} AS sguest
    ON s.guest_user_id = sguest.user_id
)

SELECT
  pro.* EXCEPT(
    country_exc, country_sub,
    region_exc, region_sub,
    city_exc, city_sub,
    department_exc, department_sub
  ),

  COALESCE(country_exc, country_sub) AS country,
  COALESCE(region_exc, region_sub) AS region,
  COALESCE(city_exc, city_sub) AS city,
  COALESCE(department_exc, department_sub) AS department

FROM pro