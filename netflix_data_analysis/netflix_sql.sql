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

select  * from netflix

-- 1. Count the Number of Movies vs TV Shows
select type,count(*) as total_content FROM netflix 
GROUP by type;

-- 2. Find the Most Common Rating for Movies and TV Shows
SELECT type,rating from
(
select type,rating,count(rating),rank() over(partition by type order by count(*) desc ) as ranking from netflix
GROUP by 1,2 ) as t1
where ranking = 1

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;

-- 3. List All Movies Released in a Specific Year (e.g., 2020)
select * from netflix
where type = 'Movie' and release_year = 2020

-- 4. Find the Top 5 Countries with the Most Content on Netflix
select UNNEST(String_to_array(country,',')) as new_country,count(show_id) as total_content
from netflix
group by 1
order by 2 desc
limit 5

-- 5. Identify the Longest Movie
select title, duration from netflix where type='Movie' and duration is not null
order by split_part(duration,' ',1)::int desc

-- 6.Find Content Added in the Last 5 Years
select * from netflix
where to_date(date_added,'Month DD, YYYY') >= CURRENT_DATE - Interval '5 years'

--7.Find All Movies/TV Shows by Director 'Rajiv Chilaka'
select * from(
select *, UNNEST(STRING_TO_ARRAY(director,',')) as director_name from netflix
) as t
where director_name = 'Rajiv Chilaka'

-- 8.List All TV Shows with More Than 5 Seasons
select * from netflix 
where type = 'TV Show' 
and split_part(duration,' ',1)::INT > 5

-- 9. Count the Number of Content Items in Each Genre
select UNNEST(string_to_array(listed_in,',')) as genre,count(*) as total_count
from netflix
group by 1

-- 10. Find each year and the average numbers of content release in India on netflix.
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;

-- 11. List All Movies that are Documentaries
select * from netflix
where listed_in like '%Documentaries'

-- 12 Find All Content Without a Director
select * from netflix
where director is null

-- 13  Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
select * from netflix
where casts like '%Salman Khan%'
and release_year > extract(year from current_date) - 10;

-- 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;

-- 15 Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
select category,count(*) as content_count
from(
select case when description ilike '%kill%' or description ilike '%violence%' Then 'bad'
else 'good'
end as category
from netflix
) as categorized_content
group by category;
