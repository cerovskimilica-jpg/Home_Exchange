-- Analyser le churn selon l’ancienneté (tenure) est le beaucoup plus informatif
-- Il évite le bias que les nouveaux entrants churnent plus que les anciens et qu'on a
-- generalement bcp de nouveaux.
select
    case
        when date_diff(subscription_date, first_subscription_date, year) = 0
        then 'Année 1'
        when date_diff(subscription_date, first_subscription_date, year) = 1
        then 'Année 2'
        when date_diff(subscription_date, first_subscription_date, year) = 2
        then 'Année 3'
        when date_diff(subscription_date, first_subscription_date, year) = 3
        then 'Année 4'
        else 'Année 5+'
    end as tenure_bucket,
    CASE 
    WHEN referral = 0 THEN "Sans parrainage"
    ELSE "Avec parrainage"
    END AS referral,
    count(*) as users,
    countif(renew = 0) as churners,
    safe_divide(countif(renew = 0), count(*)) as churn_rate
from {{ ref("stg_raw_data_subscriptions_category_clean") }}
where renew is not null
    AND country = 'FRA'
group by tenure_bucket, referral
order by tenure_bucket
