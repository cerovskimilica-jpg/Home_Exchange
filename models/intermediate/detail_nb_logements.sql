WITH base AS (
  SELECT
    user_id,
    residence_type,
    home_type,
    country_host,
    city_host,
    capacity,
    created_at,
    finalized_at,
    canceled_at
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
    -- Numérotation pour supprimer les doublons lorsque la capacity a été mal saisie
    ROW_NUMBER() OVER (
      PARTITION BY user_id, residence_type, home_type, country_host, city_host
      ORDER BY user_id DESC
    ) AS rn,

    -- Flags primary / secondary au niveau user
    MAX(CASE WHEN residence_type = 'primary' THEN 1 ELSE 0 END)
      OVER (PARTITION BY user_id) AS has_primary,
    MAX(CASE WHEN residence_type = 'secondary' THEN 1 ELSE 0 END)
      OVER (PARTITION BY user_id) AS has_secondary,

    -- Flags annuels au niveau logement (multi-lignes prises en compte) sur created_at - indique 1 si le logement a reçu au moins 1 demande dans l'année
    MAX(CASE WHEN EXTRACT(YEAR FROM created_at) = 2019 THEN 1 ELSE 0 END)
      OVER (PARTITION BY user_id, residence_type, home_type, country_host, city_host) AS y2019,
    MAX(CASE WHEN EXTRACT(YEAR FROM created_at) = 2020 THEN 1 ELSE 0 END)
      OVER (PARTITION BY user_id, residence_type, home_type, country_host, city_host) AS y2020,
    MAX(CASE WHEN EXTRACT(YEAR FROM created_at) = 2021 THEN 1 ELSE 0 END)
      OVER (PARTITION BY user_id, residence_type, home_type, country_host, city_host) AS y2021,
    MAX(CASE WHEN EXTRACT(YEAR FROM created_at) = 2022 THEN 1 ELSE 0 END)
      OVER (PARTITION BY user_id, residence_type, home_type, country_host, city_host) AS y2022,

    -- Échanges réalisés par année (finalized_at non null & cancelled_at null) - indique 1 si au moins 1 échange réalisé dans l'année par logement
    MAX(
      CASE
        WHEN finalized_at IS NOT NULL
         AND canceled_at IS NULL
         AND EXTRACT(YEAR FROM finalized_at) = 2019
        THEN 1 ELSE 0
      END
    ) OVER (PARTITION BY user_id, residence_type, home_type, country_host, city_host)
      AS exchange_realised_2019,

    MAX(
      CASE
        WHEN finalized_at IS NOT NULL
         AND canceled_at IS NULL
         AND EXTRACT(YEAR FROM finalized_at) = 2020
        THEN 1 ELSE 0
      END
    ) OVER (PARTITION BY user_id, residence_type, home_type, country_host, city_host)
      AS exchange_realised_2020,

    MAX(
      CASE
        WHEN finalized_at IS NOT NULL
         AND canceled_at IS NULL
         AND EXTRACT(YEAR FROM finalized_at) = 2021
        THEN 1 ELSE 0
      END
    ) OVER (PARTITION BY user_id, residence_type, home_type, country_host, city_host)
      AS exchange_realised_2021,

    MAX(
      CASE
        WHEN finalized_at IS NOT NULL
         AND canceled_at IS NULL
         AND EXTRACT(YEAR FROM finalized_at) = 2022
        THEN 1 ELSE 0
      END
    ) OVER (PARTITION BY user_id, residence_type, home_type, country_host, city_host)
      AS exchange_realised_2022
  FROM base
)

SELECT
  user_id,

  -- Catégorie du type de résidence
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
    WHEN capacity > 10 THEN '10+'
    ELSE 'Non renseigné'
  END AS capacity_category,

  COUNT(*) OVER (PARTITION BY user_id, residence_type) AS nb_residence_type,

  -- Colonnes annuelles (demandes) - 
  y2019,
  y2020,
  y2021,
  y2022,

  -- Colonnes annuelles (échanges réalisés) 
  exchange_realised_2019,
  exchange_realised_2020,
  exchange_realised_2021,
  exchange_realised_2022

FROM cleaned
WHERE rn = 1
ORDER BY user_id