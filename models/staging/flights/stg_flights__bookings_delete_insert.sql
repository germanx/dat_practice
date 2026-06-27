{{
  config(
    materialized = 'incremental',
    incremental_strategy = 'delete+insert',
    unique_key = ['book_ref'],
    tags = ['bookings'],
  )
}}

SELECT
  book_ref,
  book_date,
  total_amount

FROM 
  {{ source('demo_src', 'bookings') }}
{% if is_incremental() %}
WHERE 
  book_date > (SELECT MAX(book_date) FROM {{ source('demo_src', 'bookings') }}) - interval '97 days'
  {# book_date > current_date - interval '7 days' #}
{% endif %}
