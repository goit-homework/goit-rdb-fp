SET search_path TO pandemic;

SELECT
    e.entity_id,
    e.entity,
    e.code,
    ROUND(AVG(c.number_rabies), 2) AS avg_rabies,
    ROUND(MIN(c.number_rabies), 2) AS min_rabies,
    ROUND(MAX(c.number_rabies), 2) AS max_rabies,
    ROUND(SUM(c.number_rabies), 2) AS sum_rabies
FROM infectious_cases_normalized AS c
JOIN entities AS e
    ON e.entity_id = c.entity_id
WHERE c.number_rabies IS NOT NULL
GROUP BY e.entity_id, e.entity, e.code
ORDER BY AVG(c.number_rabies) DESC
LIMIT 10;
