WITH exchanges_cat AS (
    SELECT
        guest_user_id,
        created_at,
        finalized_at,
        guest_countguest_count,
        CASE
            WHEN guest_countguest_count = 1 THEN '1 solo'
            WHEN guest_countguest_count = 2 THEN '2 couple'
            WHEN guest_countguest_count BETWEEN 3 AND 5 THEN '3-5 famille'
            WHEN guest_countguest_count >= 6 THEN '6+ groupe'
        END AS cat
    FROM {{ ref('sub_exchanges_adresses_HostisocodeFR') }}
    WHERE guest_user_id IS NOT NULL
      AND guest_countguest_count IS NOT NULL
      AND guest_countguest_count >= 1
      AND DATE(created_at) BETWEEN '2021-11-01' AND '2022-10-31'
),

user_latest_cat AS (
    SELECT
        guest_user_id,
        cat
    FROM (
        SELECT
            guest_user_id,
            cat,
            created_at,
            ROW_NUMBER() OVER (
                PARTITION BY guest_user_id
                ORDER BY created_at DESC
            ) AS rn
        FROM exchanges_cat
    )
    WHERE rn = 1
),

user_activity AS (
    SELECT
        guest_user_id,
        COUNT(created_at) AS nb_demandes,
        COUNT(finalized_at) AS nb_echanges
    FROM exchanges_cat
    GROUP BY guest_user_id
),

user_subscription AS (
    SELECT
        guest_user_id,
        renew,
        MAX(DATE(last_subscription_date)) AS last_subscription
    FROM {{ ref('sub_exchanges_adresses_HostisocodeFR') }}
    WHERE guest_user_id IS NOT NULL
      AND last_subscription_date IS NOT NULL
    GROUP BY guest_user_id, renew
),

user_inactive_3m AS (
    SELECT
        s.guest_user_id,
        s.last_subscription,
        COUNT(a.created_at) AS nb_created_in_3m,
        CASE
            WHEN COUNT(a.created_at) = 0 THEN 1
            ELSE 0
        END AS inactive_3m
    FROM user_subscription s
    LEFT JOIN {{ ref('sub_exchanges_adresses_HostisocodeFR') }} a
        ON s.guest_user_id = a.guest_user_id
       AND a.created_at IS NOT NULL
       AND DATE(a.created_at) > s.last_subscription
       AND DATE(a.created_at) <= DATE_ADD(s.last_subscription, INTERVAL 3 MONTH)
    GROUP BY s.guest_user_id, s.last_subscription
),

final_user_level AS (
    SELECT
        c.cat,
        c.guest_user_id,
        a.nb_demandes,
        a.nb_echanges,
        SAFE_DIVIDE(a.nb_echanges, a.nb_demandes) AS finalisation,
        s.renew,
        COALESCE(i.inactive_3m, 1) AS inactive_3m
    FROM user_latest_cat c
    LEFT JOIN user_activity a
        ON c.guest_user_id = a.guest_user_id
    LEFT JOIN user_subscription s
        ON c.guest_user_id = s.guest_user_id
    LEFT JOIN user_inactive_3m i
        ON c.guest_user_id = i.guest_user_id
)

SELECT
    guest_user_id,
    cat,
    COALESCE(nb_demandes, 0) AS nb_demandes,
    COALESCE(nb_echanges, 0) AS nb_echanges,
    ROUND(COALESCE(finalisation, 0), 4) AS taux_de_transformation,
    CASE
        WHEN renew = 0 THEN 1
        ELSE 0
    END AS churn,
    CASE
        WHEN renew = 1 THEN 1
        ELSE 0
    END AS total_renew,
    inactive_3m
FROM final_user_level