-- 1.Count the number of Movies vs TV Shows
select type, count(*) as Count
from amazon_prime_titles
group by type;

-- 2.Find the most common rating for movies and TV shows
with count_rating as 
(
select type, rating, count(*) as rating_count  
from amazon_prime_titles
group by type, rating
), ranked_rating as  
( select type, rating, rating_count, rank () over(partition by type order by rating_count desc) as rank
from count_rating
group by type, rating, rating_count
)
select type, rating as common_rating
from ranked_rating
where rank =1;

-- 3.List all movies released in a specific year (e.g., 2020)
select * 
from amazon_prime_titles
where release_year = 2020;

-- 4.Find the top 5 countries with the most content on Amazon Prime Video
select top 5 trim(value) as Country, count(show_id) as Total_content
from amazon_prime_titles
cross apply string_split(country, ',')
group by trim(value)
order by total_content desc;


-- 5.Identify the longest movie

WITH MovieDurations AS (
    SELECT 
        *,
        CAST(SUBSTRING(duration, 1, CHARINDEX(' ', duration) - 1) AS INT) AS DurationInMinutes
    FROM amazon_prime_titles
)
SELECT *
FROM MovieDurations
WHERE DurationInMinutes = (
    SELECT MAX(DurationInMinutes)
    FROM MovieDurations
);

-- 6.Find Content Added in the Last 5 Years
select *
from amazon_prime_titles
where cast(date_added AS date)>= DATEADD(year,-5,getdate())


-- 7.Find All Movies/TV Shows by Director 'Yash Chopra'
select * , TRIM(value)
from amazon_prime_titles
cross apply string_split(director, ',')
where TRIM(value)  = 'Yash Chopra'

-- 8.List All TV Shows with More Than 5 Seasons
select *, cast(substring(duration, 1, charindex(' ',duration)-1) as int)
from amazon_prime_titles
where type = 'TV Show' and cast(substring(duration, 1, charindex(' ',duration)-1) as int) > 5

-- 9.Count the Number of Content Items in Each Genre
select TRIM(value) as Genre, count(TRIM(value)) as Number_of_Content
from amazon_prime_titles
cross apply string_split(listed_in,',')
group by TRIM(value)
order by Genre
 
-- 10.Find each year and the numbers of content release in India on Amazon Prime Video
select top 5 release_year, COUNT(show_id) as Total_Content
from amazon_prime_titles
cross apply string_split(country, ',')
where TRIM(value) = 'India'
group by release_year, TRIM(value)
order by Total_Content desc

-- 11.List All Movies that are Documentaries
select *
from amazon_prime_titles
cross apply string_split(listed_in,',')
where type = 'Movie' and TRIM(value) = 'Documentary'

-- 12.Find All Content Without a Director
select *
from amazon_prime_titles
where director is Null

-- 13.Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
select *
from amazon_prime_titles
cross apply string_split(cast,',')
where trim(value) = 'Salman Khan' and release_year >  year(DATEADD(year,-10,GETDATE()))

-- 14.Find the Top 10 Actors/Actress Who Have Appeared in the Highest Number of Movies Produced in India
select top 10 TRIM(value) as 'Actors/Actress with highest number of movies produced in India' 
from amazon_prime_titles
cross apply string_split(cast, ',')
where country like '%India%'
group by TRIM(value)
order by COUNT(*) desc

-- 15.Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
with categorized_content as 
(
select 
case when description like '%kill%' Or description like '%voilece%' then 'Voilent_movie' 
else 'Non-Voilent_movie'
end as Category
from amazon_prime_titles
)
select *, COUNT(*) as 'Number of MOvies'
from categorized_content
group by category