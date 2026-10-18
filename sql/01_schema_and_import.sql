CREATE SCHEMA IF NOT EXISTS pandemic;
SET search_path TO pandemic;

DROP TABLE IF EXISTS infectious_cases_normalized CASCADE;
DROP TABLE IF EXISTS entities CASCADE;
DROP TABLE IF EXISTS infectious_cases CASCADE;

CREATE TABLE infectious_cases (
    entity               TEXT,
    code                 TEXT,
    year                 TEXT,
    number_yaws          TEXT,
    polio_cases          TEXT,
    cases_guinea_worm    TEXT,
    number_rabies        TEXT,
    number_malaria       TEXT,
    number_hiv           TEXT,
    number_tuberculosis  TEXT,
    number_smallpox      TEXT,
    number_cholera_cases TEXT
);

\copy infectious_cases FROM 'data/infectious_cases.csv' WITH (FORMAT csv, HEADER true)

SELECT *
FROM infectious_cases
LIMIT 5;

SELECT COUNT(*)                                              AS n_rows,
       COUNT(DISTINCT (entity, code))                        AS entity_code_pairs,
       COUNT(DISTINCT entity)                                AS entities,
       COUNT(*) FILTER (WHERE code IS NULL)                  AS rows_without_code,
       MIN(year::INTEGER)                                    AS first_year,
       MAX(year::INTEGER)                                    AS last_year,
       COUNT(*) FILTER (WHERE number_rabies IS NULL)         AS rabies_empty,
       COUNT(*) FILTER (WHERE pg_input_is_valid(number_rabies, 'numeric')) AS rabies_numeric,
       COUNT(*) FILTER (WHERE number_rabies = '')            AS rabies_empty_strings
FROM infectious_cases;
