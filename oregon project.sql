drop table if exists oregon_diseases;

create table oregon_diseases (
row_id INT not null primary key,
first_day_week date,
last_day_week date,
mmwr_week INT,
mmwr_year int,
disease varchar(69),
cases int
);


load data local infile 'C:\\Users\\USER PC\\Downloads\\Oregon_Project\\Oregon.csv'
into table oregon_diseases
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 lines
(row_id , first_day_week, last_day_week, mmwr_week, mmwr_year, disease, cases);

-- 1) Overview: Checking the data ranges
 SELECT
  COUNT(*)        AS n_rows,
  MIN(first_day_week) AS min_week,
  MAX(first_day_week) AS max_week,
  MIN(mmwr_year) AS min_year,
  MAX(mmwr_year) AS max_year
FROM oregon_diseases;


-- 2) Disease ranking: total burden over all years

SELECT
  disease,
  SUM(cases) AS total_cases
FROM oregon_diseases
GROUP BY disease
ORDER BY total_cases DESC;

-- → Use this result to choose a focus disease, e.g. 'Chlamydia'.
--   Replace 'Chlamydia' below with whatever you pick.

------------------------------------------------------------
-- 3) Weekly time series for one disease
--    Question: how do weekly counts evolve over time?
------------------------------------------------------------
SELECT
  first_day_week,
  cases
FROM oregon_diseases
WHERE disease = 'Chlamydia'
ORDER BY first_day_week;

------------------------------------------------------------
-- 4) Yearly totals for that disease
--    Question: is annual burden rising, stable, or falling?
------------------------------------------------------------
SELECT
  mmwr_year,
  SUM(cases) AS total_cases
FROM oregon_diseases
WHERE disease = 'Chlamydia'
GROUP BY mmwr_year
ORDER BY mmwr_year;

------------------------------------------------------------
-- 5) 4‑week moving average (trend smoothing) – MySQL 8+
--    Question: what is the smoothed trend, ignoring week‑to‑week noise?
------------------------------------------------------------
SELECT
  first_day_week,
  cases,
  AVG(cases) OVER (
    ORDER BY first_day_week
    ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
  ) AS ma_4_week
FROM oregon_diseases
WHERE disease = 'Chlamydia'
ORDER BY first_day_week;

------------------------------------------------------------
-- 6) Seasonality pattern by MMWR week
--    Question: which weeks of the year tend to be higher on average?
------------------------------------------------------------
SELECT
  mmwr_week,
  AVG(cases) AS avg_cases
FROM oregon_diseases
WHERE disease = 'Chlamydia'
GROUP BY mmwr_week
ORDER BY mmwr_week;

------------------------------------------------------------
-- 7) Comparison of two diseases by year
--    Question: how do their yearly trends compare?
------------------------------------------------------------
SELECT
  mmwr_year,
  disease,
  SUM(cases) AS total_cases
FROM oregon_diseases
WHERE disease IN ('Chlamydia', 'Gonorrhea')
GROUP BY mmwr_year, disease
ORDER BY mmwr_year, disease;
