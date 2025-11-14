-- Netflix Project 
USE netflix_db1;
CREATE TABLE netflix_
(
	 show_id VARCHAR(6),
     type VARCHAR(10),
     title VARCHAR(150),
     director VARCHAR(208),
     cast VARCHAR(1000),
     country VARCHAR(150),
     date_added VARCHAR(50),
     release_year INT,
     rating VARCHAR(10),
     duration VARCHAR(15),
     listed_in VARCHAR(100),
     description VARCHAR(250)
);
SELECT * FROM netflix_;

SELECT 
     COUNT(*) AS total_content
FROM netflix_;

SELECT 
     DISTINCT type
FROM netflix_;

SELECT * FROM netflix_;

-- 15 Bisiness Problems

-- 1.Count the number of movies vs TV Shows

SELECT 
	 type,
     COUNT(*) AS total_content
FROM netflix_
GROUP BY type;

-- 2. Find the most common rating for movies and TV Shows

SELECT
    type,
    rating
FROM (
    SELECT
        type,
        rating,
        COUNT(*) AS total,
        RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS ranking
    FROM netflix_
    GROUP BY type, rating
) AS t1
WHERE ranking = 1;

-- 3. List all movies released in a specific year (e.g., 2020)

-- filter 2020
-- movies

SELECT * FROM netflix_
WHERE
    type = 'Movie'
    AND
    release_year = 2020;

-- 4. Find the top 5 countries with the most content on Netflix

SELECT 
     country,
     COUNT(show_id) AS total_content
FROM netflix_
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;

-- 5. Identify the longest movie ?

SELECT * FROM  netflix_
WHERE 
     type = 'Movie'
     AND 
     duration = (SELECT MAX(duration) FROM  netflix_);
     
-- 6. Find content added in the last 5 years

SELECT CURRENT_DATE - INTERVAL 5 YEAR;

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'

SELECT 
    *
FROM
    netflix_
WHERE
    director LIKE '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons

SELECT 
     *
FROM netflix_     
WHERE type = 'TV show'
AND CAST(SUBSTRING_INDEX(duration, ' ' ,1) AS UNSIGNED) > 5;

-- 9. Count the number of content items in each genre

WITH RECURSIVE split_genre AS (
  SELECT
    show_id,
    TRIM(SUBSTRING_INDEX(listed_in, ',', 1)) AS genre,
    SUBSTRING(listed_in, LENGTH(SUBSTRING_INDEX(listed_in, ',', 1)) + 2) AS rest
  FROM netflix_

  UNION ALL

  SELECT
    show_id,
    TRIM(SUBSTRING_INDEX(rest, ',', 1)),
    SUBSTRING(rest, LENGTH(SUBSTRING_INDEX(rest, ',', 1)) + 2)
  FROM split_genre
  WHERE rest <> ''
)
SELECT genre, COUNT(show_id) AS total_content
FROM split_genre
WHERE genre <> ''
GROUP BY genre
ORDER BY total_content DESC;

-- 10. Find each year and the avaerage numbers of content release in india on netflix.

-- total content 333/972
SELECT
    YEAR(STR_TO_DATE(date_added, '%M %d, %Y')) AS year,
    COUNT(*) AS yearly_content,
    ROUND(
        (COUNT(*) / (SELECT COUNT(*) FROM netflix_ WHERE country = 'India')) * 100,
        2
    ) AS avg_content_percentage
FROM netflix_
WHERE country = 'India'
GROUP BY year
ORDER BY yearly_content DESC
LIMIT 5;

-- 11. List all movies that are documentaries

SELECT * 
FROM netflix_
WHERE listed_in LIKE '%documentaries%';

-- 12. Find all content without a director
SELECT * FROM netflix_
WHERE 
     director is NULL;
     
-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years

SELECT COUNT(*) AS total_movies 
FROM netflix_
WHERE cast LIKE '%Salman Khan%'
    AND YEAR(release_year) >= YEAR(CURDATE()) - 10; 
         
-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in 

SELECT cast, COUNT(*) AS total_movies
FROM netflix_
WHERE country LIKE '%India%'
GROUP BY cast
ORDER BY total_movies DESC
LIMIT 10;

-- 15. Categorize the content on the presence of the keywords 'kill' and 'violence' in the description field.
-- Lable content containing there keywords as 'Bad' and all other content as 'Good'.
-- Count how many items fall into each category.

WITH new_table
AS
(
SELECT *, 
	CASE
    WHEN description LIKE '%kill%' OR 
        description LIKE '%violence%' THEN 'Bad_Content'
        ELSE 'Good Content'
	END category
FROM netflix_
)
SELECT 
     category,
     COUNT(*) AS total_content
FROM new_table
GROUP BY 1;

