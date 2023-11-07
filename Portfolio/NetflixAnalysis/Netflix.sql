SELECT *
FROM NetflixTitles
--|DATA CLEANING|

--changing date format 
SELECT date_added
FROM NetflixTitles
SELECT date_added ,CONVERT(date, date_added )
FROM NetflixTitles
ALTER TABLE NetflixTitles
ADD dateconverted DATE
UPDATE NetflixTitles
SET dateconverted = CONVERT(date, date_added )
SELECT *
FROM NetflixTitles

--checking for duplicates
SELECT title, COUNT(*) as Duplicates
FROM NetflixTitles
GROUP BY  title
HAVING COUNT(*)>1

--some movies were added twice 
SELECT show_id ,COUNT(*)
FROM NetflixTitles
GROUP BY  show_id
HAVING COUNT(*)>1
--no duplicates 

--checking for null values 

SELECT
  COUNT(CASE WHEN show_id IS NULL THEN 1 END) as showid_nulls,
  COUNT(CASE WHEN type IS NULL THEN 1 END) as type_nulls,
  COUNT(CASE WHEN title IS NULL THEN 1 END) as title_nulls,
  COUNT(CASE WHEN director IS NULL THEN 1 END) as director_nulls,
  COUNT(CASE WHEN cast IS NULL THEN 1 END) as cast_nulls,
  COUNT(CASE WHEN country IS NULL THEN 1 END) as country_nulls,
  COUNT(CASE WHEN date_added IS NULL THEN 1 END) as date_added_nulls,
  COUNT(CASE WHEN release_year IS NULL THEN 1 END) as release_year_nulls,
  COUNT(CASE WHEN rating IS NULL THEN 1 END) as rating_nulls,
  COUNT(CASE WHEN duration IS NULL THEN 1 END) as duration_nulls,
  COUNT(CASE WHEN listed_in IS NULL THEN 1 END) as listed_in_nulls,
  COUNT(CASE WHEN description IS NULL THEN 1 END) as description_nulls
FROM NetflixTitles

-- null values 
-- director=2634
-- cast=825
-- country=831
-- date_added=98
-- ratings=4
-- duration=3

--|GETTING RID OF NULL VALUES BY POPULATING|
--populate director with cast 

ALTER TABLE NetflixTitles
ALTER COLUMN director NVARCHAR(MAX)

UPDATE NetflixTitles
SET director = cast
WHERE director IS NULL ;

SELECT COUNT(CASE WHEN director IS NULL THEN 1 ELSE NULL END) AS director_null_count
FROM NetflixTitles ;

UPDATE NetflixTitles
SET director = cast
WHERE director IS NULL

SELECT COALESCE(nt.cast, nt2.cast)
FROM NetflixTitles AS nt
JOIN NetflixTitles AS nt2
ON nt.director = nt2.director
AND nt.show_id <> nt2.show_id
WHERE nt.cast IS NULL;
UPDATE nt
SET nt.cast = nt2.cast
FROM NetflixTitles as nt
JOIN NetflixTitles AS nt2
ON nt.director = nt2.director
AND nt.show_id <> nt2.show_id
WHERE nt.cast IS NULL
SELECT COUNT(CASE WHEN cast  IS NULL THEN 1 ELSE NULL END) AS director_null_count
FROM NetflixTitles ;
--populate cast with director 
UPDATE NetflixTitles
SET cast = director
WHERE cast  IS NULL 
--populate the remaining null values in director and cast as not given 
UPDATE NetflixTitles
SET director = 'Not Given'
WHERE director IS NULL

UPDATE NetflixTitles
SET cast  = 'Not Given'
WHERE cast IS NULL

SELECT nt1.country, nt2.country
FROM NetflixTitles AS nt1
JOIN NetflixTitles AS nt2
ON nt1.director = nt2.director
AND nt1.show_id <> nt2.show_id
WHERE nt1.country IS NULL;
UPDATE nt1
SET nt1.country = nt2.country
FROM NetflixTitles AS nt1
JOIN NetflixTitles AS nt2
ON nt1.director = nt2.director
AND nt1.show_id <> nt2.show_id
WHERE nt1.country IS NULL;

UPDATE NetflixTitles
SET country = 'Not Given'
WHERE country IS NULL;

DELETE FROM NetflixTitles
WHERE date_added IS NULL;
DELETE FROM NetflixTitles
WHERE rating IS NULL;
DELETE FROM NetflixTitles
WHERE duration IS NULL;

--|DATA ANALYSIS|

--Top Director who produced the most works on Netflix 
SELECT director , COUNT(*)
FROM NetflixTitles
GROUP BY director
ORDER BY COUNT(*) DESC
--Top 10 movies with the highest rating 
SELECT title ,rating ,COUNT(*)
FROM NetflixTitles
WHERE type ='Movie'
GROUP BY title ,rating
ORDER BY COUNT(*) DESC
--list all unique directors on Netflix 
SELECT DISTINCT( director)
FROM NetflixTitles
--total number of movies and Tv shows available in netflix 
SELECT *
FROM NetflixTitles

SELECT type,COUNT(*)
FROM NetflixTitles 
WHERE type LIKE '%Movie%'
GROUP BY type
UNION ALL
SELECT type,COUNT(*)
FROM NetflixTitles 
WHERE type LIKE '%TV Show%'
GROUP BY type
--movies and TV produced by 10 highest producing countries 
SELECT type , country,COUNT(*)
FROM NetflixTitles
GROUP BY type, country 
ORDER BY COUNT(*) desc 
OFFSET 0 ROWS FETCH FIRST 10 ROWS ONLY
--find the total number of tv shows released in a year 
SELECT release_year, COUNT(*) AS count
FROM NetflixTitles
WHERE type = 'TV Show'
GROUP BY release_year
ORDER BY COUNT(*) DESC;
--find average duration of movies released each year 
SELECT release_year, AVG(CAST(SUBSTRING(duration, 1, CHARINDEX(' ', duration) - 1) AS INT)) AS avg_duration
FROM NetflixTitles
WHERE type = 'Movie'
GROUP BY release_year
ORDER BY release_year;
--list TV shows with more than 5 seasons 
SELECT title, duration
FROM NetflixTitles
WHERE type = 'TV Show' AND CAST(SUBSTRING(duration, 1, CHARINDEX(' ', duration) - 1) AS INT) > 5;
--find the number pf movies and TV shows for each category
SELECT rating, type, COUNT(*) AS count
FROM NetflixTitles
GROUP BY rating, type
ORDER BY rating, type;