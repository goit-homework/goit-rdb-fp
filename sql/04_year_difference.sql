SET search_path TO pandemic;

SELECT
    e.entity,
    c.year,
    make_date(c.year, 1, 1)                                                AS year_start,
    CURRENT_DATE                                                           AS today,
    EXTRACT(YEAR FROM age(CURRENT_DATE, make_date(c.year, 1, 1)))::INTEGER AS years_diff
FROM infectious_cases_normalized AS c
JOIN entities AS e
    ON e.entity_id = c.entity_id
ORDER BY e.entity, c.year
LIMIT 10;

SELECT
    MIN(c.year)                                                                 AS first_year,
    MAX(EXTRACT(YEAR FROM age(CURRENT_DATE, make_date(c.year, 1, 1))))::INTEGER AS max_years_diff,
    MAX(c.year)                                                                 AS last_year,
    MIN(EXTRACT(YEAR FROM age(CURRENT_DATE, make_date(c.year, 1, 1))))::INTEGER AS min_years_diff,
    COUNT(*) FILTER (
        WHERE EXTRACT(YEAR FROM age(CURRENT_DATE, make_date(c.year, 1, 1)))
              <> EXTRACT(YEAR FROM CURRENT_DATE) - c.year)                      AS rows_where_age_differs_from_subtraction
FROM infectious_cases_normalized AS c;
