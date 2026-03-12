-- Query pour obtenir l'adresse par host en ne retenant que la dernière adresse de l'host

WITH adresse_host AS (
SELECT 
host_user_id, 
last_subscription_date,
residence_type,
country, 
region,
department,
city,
FROM `home-exchange-489808.dbt_milica.sub_exchange` 
WHERE residence_type like "primary"
GROUP BY host_user_id, last_subscription_date, residence_type, country, region, department, city
)

SELECT *
FROM (
    SELECT
        adresse_host.*,
        ROW_NUMBER() OVER (
            PARTITION BY host_user_id
            ORDER BY last_subscription_date DESC
        ) AS rn
    FROM adresse_host 
) x
WHERE rn = 1;