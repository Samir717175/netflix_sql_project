# Netflix Movies and TV Shoes Data Analysis using SQL
![Netflix_logo](https://github.com/Samir717175/netflix_sql_project/blob/main/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT 
	 type,
     COUNT(*) AS total_content
FROM netflix_
GROUP BY type;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
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
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT * FROM netflix_
WHERE
    type = 'Movie'
    AND
    release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT 
     country,
     COUNT(show_id) AS total_content
FROM netflix_
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT * FROM  netflix_
WHERE 
     type = 'Movie'
     AND 
     duration = (SELECT MAX(duration) FROM  netflix_);
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT CURRENT_DATE - INTERVAL 5 YEAR;
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT 
    *
FROM
    netflix_
WHERE
    director LIKE '%Rajiv Chilaka%';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT 
     *
FROM netflix_     
WHERE type = 'TV show'
AND CAST(SUBSTRING_INDEX(duration, ' ' ,1) AS UNSIGNED) > 5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
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
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix.
return top 5 year with highest avg content release!

```sql
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
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT * 
FROM netflix_
WHERE listed_in LIKE '%documentaries%';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT * FROM netflix_
WHERE 
     director is NULL;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT COUNT(*) AS total_movies 
FROM netflix_
WHERE cast LIKE '%Salman Khan%'
    AND YEAR(release_year) >= YEAR(CURDATE()) - 10; 
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
SELECT cast, COUNT(*) AS total_movies
FROM netflix_
WHERE country LIKE '%India%'
GROUP BY cast
ORDER BY total_movies DESC
LIMIT 10;
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.



