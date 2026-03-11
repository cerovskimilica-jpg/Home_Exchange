WITH pro AS (
  SELECT
    s.* EXCEPT(country),
    e.* EXCEPT(country),
    s.country AS country_sub,
    e.country AS country_exc,
    s.* EXCEPT(region),
    e.* EXCEPT(region),
    s.region AS region_sub,
    e.region AS region_exc,
    s.* EXCEPT(city),
    e.* EXCEPT(city),
    s.city AS city_sub,
    e.city AS city_exc,
    s.* EXCEPT(department),
    e.* EXCEPT(department),
    s.department AS department_sub,
    e.department AS department_exc,
  FROM {{ ref('stg_raw_data__exchanges') }} AS s
  LEFT JOIN {{ ref('sub_no_duplicates') }} AS e
    ON e.user_id = s.host_user_id
)

SELECT
  pro.* EXCEPT(country_sub, country_exc),
  COALESCE(country_sub, country_exc) AS country
  COALESCE(region_sub, region_exc) AS region
  COALESCE(city_sub, city_exc) AS city
  COALESCE(department_sub, department_exc) AS department
FROM pro
