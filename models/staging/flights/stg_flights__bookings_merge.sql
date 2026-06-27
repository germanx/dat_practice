{{
  config(
    materialized = 'incremental',
    incremental_strategy = 'merge',
    unique_key = ['book_ref'],
    tags = ['bookings'],
    merge_update_columns = ['total_amount'],
  )
}}

SELECT
  book_ref,
  book_date,
  total_amount
  {# total_amount::int as total_amount, #}
  {# 1 as some_amount #}

FROM 
  {{ source('demo_src', 'bookings') }}
{% if is_incremental() %}
WHERE 
  book_date > (SELECT MAX(book_date) FROM {{ source('demo_src', 'bookings') }}) - interval '97 days'
  {# book_date > current_date - interval '7 days' #}
{% endif %}
