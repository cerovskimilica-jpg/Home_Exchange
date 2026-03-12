-- Selection des exchanges finalisés - CTE: finalized_exchange
-- ajout de 2 colonnes pour les echanges qui ont été annulés par la suite - CTE: cancellation (canceled_at is not null).
-- finalize_cancel_duration : nombre de jours ecoules entre finalisaton et cancellation
-- cancel_start_duration: nombre de jours ecoules entre cancellation et le debut de l'exchange
-- Cleaning des données aberrantes - CTE cleaning1


WITH finalized_exchange as (
  SELECT *,
  FROM {{ ref('sub_exchanges_adresses') }}
  WHERE finalized_at is not null
),

enrich as (
  SELECT *,
  CASE 
    WHEN canceled_at is not null THEN DATE_DIFF(DATE(canceled_at), DATE(finalized_at), DAY)
    ELSE null
  END AS finalize_cancel_duration,
  CASE 
    WHEN canceled_at is not null THEN DATE_DIFF(DATE(start_on), DATE(canceled_at), DAY)
    ELSE null
  END AS cancel_start_duration,  
  FROM finalized_exchange
),

-- retire les échanges dont la date du sejour est anterieures ax échanges et les échanges dont le sejour debutent dans > 365 jours. Ces sejours doivent correspondrent a des erreures de saisie et faussent les analyses / retire environ 2% des lignes

cleaning1 AS (
    SELECT *,
    FROM enrich
    WHERE (cancel_start_duration BETWEEN 0 AND 365) OR (canceled_at is null)
)

SELECT *,
FROM cleaning1
