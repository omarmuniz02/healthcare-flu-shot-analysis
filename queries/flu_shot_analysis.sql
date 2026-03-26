WITH active_patients AS (
    SELECT DISTINCT e.patient
    FROM encounters e
    JOIN patients pat
      ON e.patient = pat.id
    WHERE e.start_time BETWEEN '2022-01-01 00:00:00' AND '2022-12-31 23:59:59'
      AND pat.deathdate IS NULL
      AND pat.birthdate <= DATE '2022-12-31' - INTERVAL '6 months'
),

flu_shot_2022 AS (
    SELECT patient, MIN(date_time) AS earliest_flu_shot
    FROM immunizations
    WHERE date_time BETWEEN '2022-01-01 00:00:00' AND '2022-12-31 23:59:59'
    GROUP BY patient
)

SELECT 
    pat.birthdate,
    pat.race,
    pat.county,
    pat.id,
    pat.first,
    pat.last,
    flu.earliest_flu_shot,
    CASE 
        WHEN flu.patient IS NOT NULL THEN 1
        ELSE 0
    END AS flu_shot_2022
FROM patients pat
LEFT JOIN flu_shot_2022 flu
  ON pat.id = flu.patient
WHERE pat.id IN (SELECT patient FROM active_patients);
