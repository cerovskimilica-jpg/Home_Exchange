with 

source as (

    select * from {{ source('raw_data', 'dim_calendar_') }}

),

renamed as (

    select
        date_day

    from source

)

select * from renamed