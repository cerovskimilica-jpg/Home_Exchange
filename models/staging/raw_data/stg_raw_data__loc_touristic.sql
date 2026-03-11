with 

source as (

    select * from {{ source('raw_data', 'loc_touristic') }}

),


renamed as (

    select
        activity,
        freq,
        geo,
        geo_object,
        hotel_sta,
        terrtypo,
        tour_measure,
        tour_resid,
        unit_loc_ranking,
        conf_status,
        decimals,
        obs_status,
        obs_status_fr,
        unit_mult,
        time_period,
        obs_value

    from source

),


multi AS (
    SELECT *,
        CASE
        WHEN UNIT_MULT = 0 THEN 1
        WHEN UNIT_MULT = 1 THEN 10
        WHEN UNIT_MULT = 2 THEN 100
        WHEN UNIT_MULT = 3 THEN 1000
        ELSE 0
    END AS multiplier
FROM renamed
)

select *,
    obs_value * multiplier AS obs_value_corrected
from multi