SET search_path TO pandemic;

DROP TABLE IF EXISTS infectious_cases_normalized CASCADE;
DROP TABLE IF EXISTS entities CASCADE;

CREATE TABLE entities (
    entity_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    entity    TEXT NOT NULL,
    code      TEXT,
    CONSTRAINT entities_entity_code_key UNIQUE NULLS NOT DISTINCT (entity, code),
    CONSTRAINT entities_entity_key UNIQUE (entity),
    CONSTRAINT entities_code_format CHECK (code ~ '^([A-Z]{3}|OWID_[A-Z]{3})$')
);

CREATE UNIQUE INDEX entities_code_key
    ON entities (code)
    WHERE code IS NOT NULL;

INSERT INTO entities (entity, code)
SELECT entity, code
FROM (
    SELECT DISTINCT entity, NULLIF(code, '') AS code
    FROM infectious_cases
) AS pairs
-- byte order: entity_id values stay the same under any database collation
ORDER BY entity COLLATE "C";

CREATE TABLE infectious_cases_normalized (
    entity_id            INTEGER  NOT NULL REFERENCES entities (entity_id),
    year                 SMALLINT NOT NULL CHECK (year BETWEEN 1900 AND 2100),
    number_yaws          NUMERIC CHECK (number_yaws >= 0),
    polio_cases          NUMERIC CHECK (polio_cases >= 0),
    cases_guinea_worm    NUMERIC CHECK (cases_guinea_worm >= 0),
    number_rabies        NUMERIC CHECK (number_rabies >= 0),
    number_malaria       NUMERIC CHECK (number_malaria >= 0),
    number_hiv           NUMERIC CHECK (number_hiv >= 0),
    number_tuberculosis  NUMERIC CHECK (number_tuberculosis >= 0),
    number_smallpox      NUMERIC CHECK (number_smallpox >= 0),
    number_cholera_cases NUMERIC CHECK (number_cholera_cases >= 0),
    PRIMARY KEY (entity_id, year)
);

INSERT INTO infectious_cases_normalized (
    entity_id, year, number_yaws, polio_cases, cases_guinea_worm, number_rabies,
    number_malaria, number_hiv, number_tuberculosis, number_smallpox, number_cholera_cases
)
SELECT
    e.entity_id,
    ic.year::SMALLINT,
    NULLIF(ic.number_yaws, '')::NUMERIC,
    NULLIF(ic.polio_cases, '')::NUMERIC,
    NULLIF(ic.cases_guinea_worm, '')::NUMERIC,
    NULLIF(ic.number_rabies, '')::NUMERIC,
    NULLIF(ic.number_malaria, '')::NUMERIC,
    NULLIF(ic.number_hiv, '')::NUMERIC,
    NULLIF(ic.number_tuberculosis, '')::NUMERIC,
    NULLIF(ic.number_smallpox, '')::NUMERIC,
    NULLIF(ic.number_cholera_cases, '')::NUMERIC
FROM infectious_cases AS ic
JOIN entities AS e
    ON e.entity = ic.entity
   AND e.code IS NOT DISTINCT FROM NULLIF(ic.code, '');

SELECT (SELECT COUNT(*) FROM infectious_cases)                       AS raw_rows,
       (SELECT COUNT(*) FROM infectious_cases_normalized)            AS normalized_rows,
       (SELECT COUNT(*) FROM entities)                               AS entities,
       (SELECT COUNT(*) FROM entities WHERE code IS NULL)            AS entities_without_code,
       (SELECT COUNT(*)
          FROM infectious_cases AS ic
          JOIN entities AS e
            ON e.entity = ic.entity
           AND e.code = ic.code)                                     AS rows_if_joined_with_equals;

SELECT *
FROM entities
ORDER BY entity_id
LIMIT 10;

SELECT *
FROM infectious_cases_normalized
ORDER BY entity_id, year
LIMIT 10;

SELECT table_name, ordinal_position AS pos, column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'pandemic'
  AND table_name IN ('entities', 'infectious_cases_normalized')
ORDER BY table_name, ordinal_position;

SELECT conrelid::regclass::TEXT AS table_name,
       conname,
       pg_get_constraintdef(oid) AS definition
FROM pg_constraint
WHERE connamespace = 'pandemic'::regnamespace
  AND conrelid::regclass::TEXT IN ('entities', 'infectious_cases_normalized')
  AND contype IN ('p', 'f', 'u', 'c')
ORDER BY table_name, CASE contype WHEN 'p' THEN 1 WHEN 'u' THEN 2 WHEN 'f' THEN 3 ELSE 4 END, conname;
