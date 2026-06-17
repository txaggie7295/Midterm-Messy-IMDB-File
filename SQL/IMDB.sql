--5. 
----1. Data Import:
--    * Import your cleaned data into your database tables

PRAGMA foreign_keys = 0;

CREATE TABLE sqlitestudio_temp_table AS SELECT *
                                          FROM imdb_main;

DROP TABLE imdb_main;

CREATE TABLE imdb_main (
    title_id       TEXT    PRIMARY KEY,
    original_title TEXT,
    release_year   TEXT,
    genre_1        TEXT,
    genre_2        TEXT,
    genre_3        TEXT,
    duration       INTEGER,
    country        TEXT,
    content_rating TEXT,
    director_1     TEXT,
    director_2     TEXT,
    income         NUMERIC,
    votes          NUMERIC,
    score          REAL
);

INSERT INTO imdb_main (
                          title_id,
                          original_title,
                          release_year,
                          genre_1,
                          genre_2,
                          genre_3,
                          duration,
                          country,
                          content_rating,
                          director_1,
                          director_2,
                          income,
                          votes,
                          score
                      )
                      SELECT title_id,
                             original_title,
                             release_year,
                             genre_1,
                             genre_2,
                             genre_3,
                             duration,
                             country,
                             content_rating,
                             director_1,
                             director_2,
                             income,
                             votes,
                             score
                        FROM sqlitestudio_temp_table;

DROP TABLE sqlitestudio_temp_table;

PRAGMA foreign_keys = 1;


--    * Verify data integrity after import

SELECT sum(income) 
  FROM imdb_main;
  
--    had to fix income, votes, score fields. Income and votes uploaded with commas and SQL read as texts  

----2. Data Verification:
--    * Write queries to verify row counts match your original dataset

SELECT count( * ) 
  FROM imdb_main;


--    * Check for any data type issues or constraints that need addressing

-- 6. Exploratory Query Analysis

--    * Number of movies by country

SELECT country,
       count(title_id) AS num_movies
  FROM imdb_main
 GROUP BY country;
 
--    * Total income by country

SELECT country,
       sum(income) AS total_income
  FROM imdb_main
 GROUP BY country;

--    * Min and Max score by country

SELECT country,
       min(score) AS min_score,
       max(score) AS max_score
  FROM imdb_main
 GROUP BY country;

-- 7. Business Query Analysis 

--    * Cohort analysis: counting movies and summing income by genre 

SELECT genre_1,
       count(title_id) AS num_movies,
       sum(income) as total_income
  FROM imdb_main
 GROUP BY genre_1;

--    * Showing total income, ranked income, and total movies by content rating

SELECT content_rating,
       count(title_id) AS num_movies,
       sum(income) AS total_income,
       rank() OVER (ORDER BY sum(income) DESC) AS income_ranking
  FROM imdb_main
 GROUP BY content_rating;
 
--    * 
-- 1. Overall correlation between score and income

WITH tiered AS (
    SELECT 
        CASE 
            WHEN score >= 9.0 THEN 'A: Masterpiece (9.0+)'
            WHEN score >= 8.5 THEN 'B: Acclaimed (8.5-8.9)'
            WHEN score >= 8.0 THEN 'C: Very Good (8.0-8.4)'
            ELSE 'D: Good (7.4-7.9)'
        END AS score_tier,
        income
    FROM imdb_main
)
SELECT 
    score_tier,
    COUNT(*) AS films,
    (Select count(*) from imdb_main) as total_films,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM imdb_main), 1) AS pct_of_films,      
    ROUND(AVG(income), 0) AS avg_income, 
    --sum(income) as tier_income,    
    --(select sum(income) from imdb_main) as total_income,    
    ROUND(100.0 * SUM(income) / (SELECT SUM(income) FROM imdb_main), 1) AS pct_of_income,
    ROUND(
        (100.0 * SUM(income) / (SELECT SUM(income) FROM imdb_main)) /
        (100.0 * COUNT(*) / (SELECT COUNT(*) FROM imdb_main)),2) AS density
FROM tiered
GROUP BY score_tier
ORDER BY score_tier;


WITH ranked AS (
    SELECT 
        original_title,
        score,
        income,
        RANK() OVER (ORDER BY income DESC) AS income_rank,
        RANK() OVER (ORDER BY score DESC) AS score_rank
    FROM imdb_main
    order by score_rank
)
SELECT 
    original_title,
    score,
    income,
    income_rank,
    score_rank,
    CASE 
        WHEN income_rank <= 10 AND score_rank <= 10 THEN 'Both lists'
        WHEN income_rank <= 10 THEN 'Top earner only'
        ELSE 'Top scorer only'
    END AS appears_in
FROM ranked
WHERE income_rank <= 10 OR score_rank <= 10
ORDER BY appears_in, income_rank, score_rank;







