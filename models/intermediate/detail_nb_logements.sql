WITH base AS (
  SELECT
    user_id,
    residence_type,
    home_type,
    country_host,
    city_host,
    capacity,

    -- Numérotation pour supprimer les doublons lorsque la capacity a été mal saisie
    ROW_NUMBER() OVER (
      PARTITION BY user_id, residence_type, home_type, country_host, city_host
      ORDER BY user_id DESC
    ) AS rn
  FROM `home-exchange-489808.dbt_abrissiet.sub_exchanges_adresses_HostisocodeFR`
  WHERE user_id IS NOT NULL
    AND residence_type IS NOT NULL
    AND home_type IS NOT NULL
    AND country_host IS NOT NULL
    AND city_host IS NOT NULL
),

cleaned AS (
  SELECT
    *,
    -- Nombre de résidences par type
    COUNT(*) OVER (PARTITION BY user_id, residence_type) AS nb_residence_type,

    -- Flags pour savoir si un user possède primary / secondary
    MAX(CASE WHEN residence_type = 'primary' THEN 1 ELSE 0 END)
      OVER (PARTITION BY user_id) AS has_primary,
    MAX(CASE WHEN residence_type = 'secondary' THEN 1 ELSE 0 END)
      OVER (PARTITION BY user_id) AS has_secondary
  FROM base
  WHERE rn = 1
)

SELECT
  user_id,
  residence_type,
    -- Nouvelle colonne : catégorie du type de résidence
  CASE
    WHEN has_primary = 1 AND has_secondary = 0 THEN 'Only primary'
    WHEN has_primary = 0 AND has_secondary = 1 THEN 'Only secondary'
    WHEN has_primary = 1 AND has_secondary = 1 THEN 'Primary + Secondary'
    ELSE 'Unknown'
  END AS categorie_residence,

  home_type,
  country_host,
  city_host,
  capacity,

  -- Catégorisation de la capacité
  CASE
    WHEN capacity = 1 THEN '1'
    WHEN capacity = 2 THEN '2'
    WHEN capacity BETWEEN 3 AND 5 THEN '3-5'
    WHEN capacity BETWEEN 6 AND 10 THEN '6-10'
    WHEN capacity > 10 THEN '+10'
    ELSE 'Non renseigné'
  END AS capacity_category,

  nb_residence_type,

FROM cleaned
ORDER BY user_id