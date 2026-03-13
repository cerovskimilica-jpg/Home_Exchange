WITH users_last_sub AS (
    SELECT
        user_id,
        country_host,
        exchange_type,
        MAX(DATE(last_subscription_date)) AS last_subscription
    FROM `home-exchange-489808.dbt_aengelke.sub_exchange`
    WHERE user_id IS NOT NULL
      AND last_subscription_date IS NOT NULL
    GROUP BY user_id, country_host, exchange_type
),

exchange_activity AS (
    SELECT
        u.user_id,
        u.country_host,
        u.last_subscription,
        u.exchange_type,

        COUNTIF(
            DATE(s.created_at) > u.last_subscription
            AND DATE(s.created_at) <= DATE_ADD(u.last_subscription, INTERVAL 3 MONTH)
            AND s.guest_user_id = u.user_id
        ) AS guest_requests_3m,

        COUNTIF(
            DATE(s.created_at) > u.last_subscription
            AND DATE(s.created_at) <= DATE_ADD(u.last_subscription, INTERVAL 3 MONTH)
            AND s.host_user_id = u.user_id
        ) AS host_requests_3m,

        MIN(
            IF(
                DATE(s.created_at) > u.last_subscription
                AND DATE(s.created_at) <= DATE_ADD(u.last_subscription, INTERVAL 3 MONTH)
                AND s.guest_user_id = u.user_id,
                DATE(s.created_at),
                NULL
            )
        ) AS first_guest_request_3m,

        MIN(
            IF(
                DATE(s.created_at) > u.last_subscription
                AND DATE(s.created_at) <= DATE_ADD(u.last_subscription, INTERVAL 3 MONTH)
                AND s.host_user_id = u.user_id,
                DATE(s.created_at),
                NULL
            )
        ) AS first_host_request_3m,

        MIN(
            IF(
                s.guest_user_id = u.user_id
                AND s.finalized_at IS NOT NULL
                AND DATE(s.finalized_at) > u.last_subscription
                AND DATE(s.finalized_at) <= DATE_ADD(u.last_subscription, INTERVAL 3 MONTH),
                DATE(s.finalized_at),
                NULL
            )
        ) AS first_finalized_guest_exchange,

        COUNTIF(
            s.finalized_at IS NOT NULL
            AND DATE(s.finalized_at) <= DATE_ADD(u.last_subscription, INTERVAL 3 MONTH)
            AND ( s.host_user_id = u.user_id)
        ) AS nb_finalized_exchange,

        ANY_VALUE(
            IF(
                DATE(s.created_at) > u.last_subscription
                AND DATE(s.created_at) <= DATE_ADD(u.last_subscription, INTERVAL 3 MONTH),
                s.country_guestdf,
                NULL
            )
        ) AS country_guestdf

    FROM users_last_sub AS u
    LEFT JOIN `home-exchange-489808.dbt_aengelke.sub_exchanges_adresses` AS s
        ON (u.user_id = s.guest_user_id OR u.user_id = s.host_user_id)
    WHERE u.country_host = 'FRA'
    GROUP BY u.user_id, u.country_host, u.last_subscription, u.exchange_type
)

SELECT
    user_id,
    last_subscription, 
    guest_requests_3m,
    host_requests_3m,
    nb_finalized_exchange,
    CASE
        WHEN guest_requests_3m = 0 AND nb_finalized_exchange = 0 -- s'il n'a pas fais de demande en tant que guest et qu'il n'a pas finalisé en tant que host dans les 3 mois, alors INACTIF 
        THEN 1      -- Inactif
        ELSE 0      -- Actif 
    END AS inactive_3m,
    first_guest_request_3m,
    first_host_request_3m,
    first_finalized_guest_exchange,
    country_guestdf,
    country_host,
    exchange_type,

    CASE 
        WHEN country_guestdf = 'FRA' THEN 1
        WHEN country_host = 'FRA' THEN 1
        ELSE 0
    END AS user_french,

    CASE
        WHEN country_guestdf != 'FRA' THEN 1
        ELSE 0
    END AS french_travel_abroad

FROM exchange_activity
ORDER BY last_subscription DESC