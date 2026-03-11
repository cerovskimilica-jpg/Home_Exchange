with 

source as (

    select * from {{ source('raw_data', 'department_FR') }}

),

renamed as (

    select
        country,
        department_code,
        department_isocode,
        department_name,
        region_name

    from source

)

select * from renamed