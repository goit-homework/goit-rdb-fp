SET search_path TO pandemic;

CREATE OR REPLACE FUNCTION years_since(p_year INTEGER)
RETURNS INTEGER
LANGUAGE sql
STABLE
AS $$
    SELECT EXTRACT(YEAR FROM age(CURRENT_DATE, make_date(p_year, 1, 1)))::INTEGER
$$;

CREATE OR REPLACE FUNCTION avg_cases_per_period(p_yearly_cases NUMERIC, p_divisor NUMERIC)
RETURNS NUMERIC
LANGUAGE sql
IMMUTABLE
STRICT
AS $$
    SELECT p_yearly_cases / NULLIF(p_divisor, 0)
$$;

SELECT p.proname                                      AS function_name,
       pg_get_function_arguments(p.oid)               AS arguments,
       pg_get_function_result(p.oid)                  AS returns,
       CASE p.provolatile WHEN 'i' THEN 'IMMUTABLE'
                          WHEN 's' THEN 'STABLE'
                          ELSE 'VOLATILE' END         AS volatility,
       p.proisstrict                                  AS strict
FROM pg_proc AS p
WHERE p.pronamespace = 'pandemic'::regnamespace
ORDER BY p.proname;

SELECT
    e.entity,
    c.year,
    years_since(c.year) AS years_diff
FROM infectious_cases_normalized AS c
JOIN entities AS e
    ON e.entity_id = c.entity_id
WHERE e.code = 'UKR'
ORDER BY c.year
LIMIT 10;

SELECT years_since(1996)                                             AS years_since_1996,
       COUNT(*)                                                       AS rows_checked,
       COUNT(*) FILTER (
           WHERE years_since(c.year)
                 <> EXTRACT(YEAR FROM age(CURRENT_DATE, make_date(c.year, 1, 1)))::INTEGER
       )                                                              AS mismatches_with_task4
FROM infectious_cases_normalized AS c;

SELECT
    e.entity,
    c.year,
    ROUND(c.number_rabies, 4)                               AS rabies_per_year,
    ROUND(avg_cases_per_period(c.number_rabies, 12), 2)     AS avg_per_month,
    ROUND(avg_cases_per_period(c.number_rabies, 4), 2)      AS avg_per_quarter,
    ROUND(avg_cases_per_period(c.number_rabies, 2), 2)      AS avg_per_half_year
FROM infectious_cases_normalized AS c
JOIN entities AS e
    ON e.entity_id = c.entity_id
WHERE c.number_rabies IS NOT NULL
  AND e.code = 'UKR'
ORDER BY c.year DESC
LIMIT 10;

SELECT
    COUNT(*)                                                      AS raw_rows,
    COUNT(*) FILTER (WHERE pg_input_is_valid(number_rabies, 'numeric')) AS numeric_rows_used,
    ROUND(SUM(avg_cases_per_period(number_rabies::NUMERIC, 12))
          FILTER (WHERE pg_input_is_valid(number_rabies, 'numeric')), 2) AS total_monthly_average,
    ROUND(SUM(number_rabies::NUMERIC)
          FILTER (WHERE pg_input_is_valid(number_rabies, 'numeric')) / 12, 2) AS same_via_sum_div_12,
    avg_cases_per_period(120, 0)                                  AS divisor_zero_gives,
    avg_cases_per_period(NULL, 12)                                AS null_cases_give
FROM infectious_cases;
