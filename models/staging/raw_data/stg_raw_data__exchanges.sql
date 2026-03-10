with 

source as (

    select * from {{ source('raw_data', 'exchanges') }}

),

renamed as (

    select
        conversation_id,
        exchange_id,
        created_at,
        creator_id,
        guest_user_id,
        host_user_id,
        finalized_at,
        canceled_at,
        start_on,
        end_on,
        guest_countguest_count,
        night_count,
        user_cancellation_id,
        exchange_type,
        home_type,
        residence_type,
        capacity,
        country,
        region,
        department,
        city

    from source

)

select * from renamed