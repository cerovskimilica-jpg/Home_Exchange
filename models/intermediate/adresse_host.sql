-- Query pour obtenir l'adresse par host en ne retenant que la dernière adresse de l'host

WITH adresse_host AS (
SELECT 
host_user_id, 
last_subscription_date,
residence_type,
country_host, 
region_host,
department_host,
city_host,
FROM {{ ref('sub_exchange') }}
WHERE residence_type like "primary"
GROUP BY host_user_id, last_subscription_date, residence_type, country_host, region_host, department_host, city_host
)

SELECT *
FROM (
    SELECT
        adresse_host.*,
        ROW_NUMBER() OVER (
            PARTITION BY host_user_id
            ORDER BY last_subscription_date DESC
        ) AS row_number_def
    FROM adresse_host 
) x
WHERE row_number_def = 1