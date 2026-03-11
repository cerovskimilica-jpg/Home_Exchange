SELECT DISTINCT
  country,
  department_name,
    CASE
    WHEN department_name = 'Tarn-et-Garonne' THEN 'Tarn-Et-Garonne'
    WHEN department_name = 'Territoire de Belfort' THEN 'Territoire De Belfort'
    WHEN department_name = 'Val-d’Oise' THEN "Val-D'oise"
    WHEN department_name = 'Val-de-Marne' THEN 'Val-De-Marne'
    WHEN department_name = 'Hauts-de-Seine' THEN 'Hauts-De-Seine'
    WHEN department_name = 'Seine-et-Marne' THEN 'Seine-Et-Marne'
    WHEN department_name = 'Maine-et-Loire' THEN 'Maine-Et-Loire'
    WHEN department_name = 'Bouches-du-Rhône' THEN 'Bouches-Du-Rhône'
    WHEN department_name = 'Alpes-de-Haute-Provence' THEN 'Alpes-De-Haute-Provence'
    ELSE department_name
  END AS department_FR_clean
FROM {{ ref('stg_raw_data__department_FR') }}
WHERE country = 'France'
