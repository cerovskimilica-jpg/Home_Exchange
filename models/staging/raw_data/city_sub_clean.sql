SELECT
  * EXCEPT(city),
    CASE
    WHEN city = 'Chamb½uf' THEN 'Chamboeuf'
    WHEN city = 'H½nheim' THEN 'Hoenheim'
    WHEN city = 'H½rdt' THEN 'Hoerdt'
    WHEN city = 'Bergholtz?Zell' THEN 'Bergholtzzell'
    WHEN city = 'Fr½ningen' THEN 'Froeningen'
    WHEN city = 'Vand½uvre-Lès-Nancy' THEN 'Vandoeuvre-lès-Nancy'
    WHEN city = 'J½uf' THEN 'Joeuf'
    WHEN city = 'Vasc½uil' THEN 'Vascoeuil'
    WHEN city = 'Escorneb½uf' THEN 'Escorneboeuf'
    WHEN city IN ('St.-Ouen','Saint-Ouen') THEN 'Saint-Ouen-sur-Seine'
    WHEN city = 'Marcq-En-Bar½ul' THEN 'Marcq-En-Baroeul'
    WHEN city = 'Mons-En-Bar½ul' THEN 'Mons-En-Baroeul'
    WHEN city = 'Paimb½uf' THEN 'Paimboeuf'
    WHEN city = 'Salleb½uf' THEN 'Salleboeuf'
    ELSE city
  END AS city_clean
FROM {{ ref('stg_raw_data_subscriptions_category_clean') }}

