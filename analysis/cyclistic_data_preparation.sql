-- =============================================================================
-- CYCLISTIC BIKE-SHARE ANALYSIS | 2025
-- Data Preparation & Cleaning Pipeline
-- Tool: Google BigQuery (Standard SQL)
-- Author: jeankash
-- Last Updated: June 2025
-- =============================================================================
-- PIPELINE OVERVIEW
--   Step 1 | Combine monthly CSV files into a single annual table (Wildcard)
--   Step 2 | Clean data and engineer features using a CTE
--   Step 3 | Slim down table by dropping raw timestamp columns
--   Step 4 | Audit bad data (negative durations, nulls, out-of-range rides)
--   Step 5 | Remove invalid records and finalize cleaned table
-- =============================================================================


-- -----------------------------------------------------------------------------
-- STEP 1 | COMBINE MONTHLY FILES → 2025_year_combined
-- -----------------------------------------------------------------------------
-- Context:
--   Each month's ride data was uploaded as a separate CSV to BigQuery.
--   Each file contained 130,000+ entries. After inspecting three months in
--   Excel and confirming identical schema across all files, the SQL wildcard
--   method was used to combine all months in a single query rather than
--   manually unioning 12 tables.

CREATE OR REPLACE TABLE `test-project-468922.Cyclistic_rides.2025_year_combined` AS
SELECT
  *
FROM
  `test-project-468922.Cyclistic_rides.2025*`
WHERE
  _TABLE_SUFFIX LIKE '%_rides'
  AND _TABLE_SUFFIX BETWEEN '01_rides' AND '12_rides';


-- -----------------------------------------------------------------------------
-- STEP 2 | FEATURE ENGINEERING & CLEANING → 2025_year_cleaned (CTE)
-- -----------------------------------------------------------------------------
-- Context:
--   Columns not relevant to this analysis were dropped:
--     ride_id, start/end station names & IDs, geographic coordinates (lat/lng)
--
--   New columns engineered:
--     ride_duration  → calculated in minutes using TIMESTAMP_DIFF
--     Day_name       → day of week (e.g., Monday) extracted from started_at
--     Month          → month name (e.g., January) extracted from started_at
--     Hour           → hour of day (0–23) extracted from started_at
--     Duration_cat   → ride duration bucketed into 6 categories
--
--   Why a CTE?
--     BigQuery does not allow referencing a newly created column (ride_duration)
--     in the same SELECT to derive another column (Duration_cat). The CTE
--     resolves this by making ride_duration available as a named reference
--     in the outer SELECT.

CREATE OR REPLACE TABLE `test-project-468922.Cyclistic_rides.2025_year_cleaned` AS
WITH base_data AS (
  SELECT
    * EXCEPT(
      ride_id,
      start_station_name,
      start_station_id,
      end_station_name,
      end_station_id,
      start_lat,
      start_lng,
      end_lat,
      end_lng
    ),
    -- Duration in minutes (decimal precision)
    TIMESTAMP_DIFF(ended_at, started_at, SECOND) / 60.0 AS ride_duration,
    -- Time-based features for behavioral analysis
    FORMAT_TIMESTAMP('%A', started_at) AS Day_name,
    FORMAT_TIMESTAMP('%B', started_at) AS Month,
    EXTRACT(HOUR FROM started_at)       AS Hour
  FROM
    `test-project-468922.Cyclistic_rides.2025_year_combined`
)
SELECT
  *,
  CASE
    WHEN ride_duration <= 5                          THEN 'Under 5'
    WHEN ride_duration > 5  AND ride_duration <= 10  THEN '5 to 10'
    WHEN ride_duration > 10 AND ride_duration <= 15  THEN '10 to 15'
    WHEN ride_duration > 15 AND ride_duration <= 20  THEN '15 to 20'
    WHEN ride_duration > 20 AND ride_duration <= 30  THEN '20 to 30'
    WHEN ride_duration > 30 AND ride_duration <= 60  THEN 'Over 30'
    ELSE 'Outside Range'
  END AS Duration_cat
FROM
  base_data;


-- -----------------------------------------------------------------------------
-- STEP 3 | DROP RAW TIMESTAMP COLUMNS (Storage Optimization)
-- -----------------------------------------------------------------------------
-- Context:
--   started_at and ended_at were used to derive ride_duration, Day_name,
--   Month, and Hour. They are no longer needed in the cleaned table and are
--   dropped to reduce storage and simplify the working dataset.

ALTER TABLE `test-project-468922.Cyclistic_rides.2025_year_cleaned`
DROP COLUMN started_at,
DROP COLUMN ended_at;


-- -----------------------------------------------------------------------------
-- STEP 4 | DATA QUALITY AUDIT
-- -----------------------------------------------------------------------------
-- Context:
--   Before removing bad records, we audit three categories of data quality
--   issues to understand the scale of the problem:
--
--     1. Negative/Zero Duration  → system glitches or zero-second test rides
--     2. Missing/Null Data       → records where key fields are NULL
--     3. Outside 0–60 Min Range  → rides exceeding 1 hour (out of scope
--                                  for this commuter/leisure behavior analysis)

SELECT
  'Negative/Zero Duration'  AS error_type,
  COUNT(*)                  AS row_count,
  ROUND(AVG(ride_duration), 2) AS avg_val
FROM `test-project-468922.Cyclistic_rides.2025_year_cleaned`
WHERE ride_duration <= 0

UNION ALL

SELECT
  'Missing/Null Data'       AS error_type,
  COUNT(*)                  AS row_count,
  NULL                      AS avg_val
FROM `test-project-468922.Cyclistic_rides.2025_year_cleaned`
WHERE
  rideable_type  IS NULL
  OR member_casual   IS NULL
  OR ride_duration   IS NULL

UNION ALL

SELECT
  'Outside 0–60 Min Range'  AS error_type,
  COUNT(*)                  AS row_count,
  ROUND(MAX(ride_duration), 2) AS max_val
FROM `test-project-468922.Cyclistic_rides.2025_year_cleaned`
WHERE Duration_cat = 'Outside Range';


-- Pre-deletion row count check (confirm rows to be removed)
SELECT
  COUNT(*) AS rows_with_zero_or_negative_duration
FROM `test-project-468922.Cyclistic_rides.2025_year_cleaned`
WHERE ride_duration <= 0;


-- -----------------------------------------------------------------------------
-- STEP 5 | REMOVE INVALID RECORDS → Finalize 2025_year_cleaned
-- -----------------------------------------------------------------------------
-- Context:
--   Removal criteria:
--     - ride_duration <= 0    : zero or negative durations (system errors)
--     - ride_duration IS NULL : unresolvable missing values
--     - rideable_type is NULL or empty : incomplete categorical records
--     - member_casual is NULL or empty : key segmentation field missing
--     - Duration_cat = 'Outside Range' : rides > 60 min excluded from scope
--
--   The cleaned table is overwritten in place and exported to R for analysis.

CREATE OR REPLACE TABLE `test-project-468922.Cyclistic_rides.2025_year_cleaned` AS
SELECT
  *
FROM
  `test-project-468922.Cyclistic_rides.2025_year_cleaned`
WHERE
  ride_duration > 0
  AND ride_duration     IS NOT NULL
  AND rideable_type     IS NOT NULL AND rideable_type  != ''
  AND member_casual     IS NOT NULL AND member_casual  != ''
  AND Duration_cat      != 'Outside Range';

-- =============================================================================
-- END OF DATA PREPARATION PIPELINE
-- Next step: Export 2025_year_cleaned → R for statistical analysis
-- =============================================================================
