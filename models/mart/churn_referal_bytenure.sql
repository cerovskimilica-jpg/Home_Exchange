-- Analyser le churn selon l’ancienneté (tenure) est le beaucoup plus informatif
-- Il évite le bias que les nouveaux entrants churnent plus que les anciens et qu'on a
-- generalement bcp de nouveaux.
select
    case
        when date_diff(subscription_date, first_subscription_date, year) = 0
        then 'Year 1'
        when date_diff(subscription_date, first_subscription_date, year) = 1
        then 'Year 2'
        when date_diff(subscription_date, first_subscription_date, year) = 2
        then 'Year 3'
        when date_diff(subscription_date, first_subscription_date, year) = 3
        then 'Year 4'
        else 'Year 5+'
    end as tenure_bucket,
    referral,
    count(*) as users,
    countif(renew = 0) as churners,
    safe_divide(countif(renew = 0), count(*)) as churn_rate
from {{ ref("stg_raw_data_subscriptions_category_clean") }}
where renew is not null
group by tenure_bucket, referral
order by tenure_bucket
