SELECT
    conversation_id,
    exchange_id,
    created_at,
    exchange_type,
    creator_id,
    guest_user_id,
    host_user_id,
    finalized_at,
    canceled_at,
    user_cancellation_id,
    -- user_id,
    first_subscription_date,
    last_subscription_date,
    nb_subscriptions,
    returned_customer,
    renew,
    promotion,
    referral,
    country_host,
    region_host,
    department_host,
    city_host,
    department_host_isocode,
    department_attractivity_2022_decile,

FROM {{ ref('sub_exchanges_adresses_HostisocodeFR') }}
WHERE created_at between '2021-11-01' and '2022-10-31' AND country_host = 'FRA'
ORDER BY host_user_id