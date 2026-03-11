 -- TOP 10 DES DEMANDES DE LOGEMENTS EN FRANCE PAR AN 

WITH city_requests AS (
SELECT
  EXTRACT(YEAR FROM created_at) AS year,
  city,
  COUNT(*) AS nb_request
FROM {{ ref('stg_raw_data__exchanges') }}
WHERE country = 'FRA'
GROUP BY year, city
)

SELECT *
FROM (
  SELECT*,
  ROW_NUMBER() OVER(PARTITION BY year ORDER BY nb_request DESC) AS rank
  FROM city_requests
)
WHERE rank <= 10
ORDER BY year, rank