WITH base AS (
  SELECT
    user_id,
    residence_type,
    home_type,
    country_host,
    city_host,
    capacity,
    finalized_at,

    -- Numérotation pour supprimer les doublons lorsque la capacity a été mal saisie (on garde la dernière ligne)
    ROW_NUMBER() OVER (
      PARTITION BY user_id, residence_type, home_type, country_host, city_host
      ORDER BY user_id DESC
    ) AS rn
  FROM {{ ref('sub_exchanges_adresses_HostisocodeFR') }}
  WHERE user_id IS NOT NULL
    AND residence_type IS NOT NULL
    AND home_type IS NOT NULL
    AND country_host IS NOT NULL
    AND city_host IS NOT NULL
)

SELECT
  user_id,
  residence_type,
  home_type,
  country_host,
  city_host,
  capacity,

  -- Nouvelle colonne de catégorisation de la capicité par logements
  CASE
    WHEN capacity = 1 THEN '1'
    WHEN capacity = 2 THEN '2'
    WHEN capacity BETWEEN 3 AND 5 THEN '3-5'
    WHEN capacity BETWEEN 6 AND 10 THEN '6-10'
    WHEN capacity > 10 THEN '+10'
    ELSE 'Non renseigné'
  END AS capacity_category,

  -- Nombre de résidences par type par user (exemple 2 si un user détient 2 résidence primary)
  COUNT(*) OVER (PARTITION BY user_id, residence_type) AS nb_residence_type

FROM base
WHERE rn = 1   -- On garde uniquement la dernière ligne pour chaque logement si doublon de lignes (hors capacity mal saisie = un meme logement avec plusieurs capacité saisie donc créé des doublons)
ORDER BY user_id