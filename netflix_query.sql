-- Netflix Project
DROP Table netflix_data;
create table netflix_data(

	show_id VARCHAR(7) , 
	type varchar(10),
	title varchar(150) ,
	director varchar(210),
	castS varchar(1000),
	country varchar(150),
	date_added varchar(50) , 
	release_year int ,  
	rating  varchar(10), 
	duration varchar(15), 
	listed_in  varchar(100)  , 
	description varchar(300)
);
select count(*) from netflix_data;





-- Q1. Count the number of Movies vs TV Shows

SELECT 
	type,
	COUNT(*)
FROM netflix_data
GROUP BY 1

-- Q2. Find the most common rating for movies and TV shows

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix_data
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


-- Q3. List all movies released in a specific year (e.g., 2020)

SELECT * 
FROM netflix_data
WHERE release_year = 2020 and type = 'Movie'


-- Q4. Find the top 5 countries with the most content on Netflix

select
	UNNEST(string_to_array(country , ',')) as new_county,
	count(show_id) as total_count

from netflix_data
group by 1
order by 2 desc
limit 5


-- Q5 Identify the longest movie

select * from netflix_data
where 
	type = 'Movie'
	and 
	duration = (select max(duration) from netflix_data)


-- Q6  Find content added in the last 5 years


select * from netflix_data
where TO_DATE(date_added , 'Month , DD , YYYY') >= current_date - interval '5 years'

-- Q7  Find all the movies/TV shows by director 'Rajiv Chilaka'!

select * from netflix_data
where director ilike '%Rajiv Chilaka%'


-- Q8 List all TV shows with more than 5 seasons

select * from netflix_data
where 
	type = 'TV Show'
	and 
	SPLIT_PART(duration , ' '  ,1)::numeric  > 5 


select split_part(duration , ' ' ,1) < 5 from netflix_data

-- Q9 Count the number of content items in each genre
select 
	UNNEST(string_to_array(listed_in , ',')) as new_listed_in,
	count(show_id) as Total_conten
from netflix_data
group by 1


-- Q10 Find each year and the average numbers of content release in India on netflix. 
--      return top 5 year with highest avg content release!

select 
	extract(year from to_date(date_added , 'Month , DD , YYYY')) as year,
	count(*),
	round(
	count(*)::numeric / (select count(*) from netflix_data where country = 'India') ::numeric  * 100 , 2) as avg_content_per_year	
from netflix_data
where country = 'India'
group by 1

-- Q11 List all movies that are documentaries

select * from netflix_data
where listed_in ilike '%documentaries%'

-- Q12  Find all content without a director
select * from netflix_data
where director is null


-- Q13 Find how many movies actor 'Salman Khan' appeared in last 10 years!
select  * from netflix_data
where 
	casts ilike '%Salman Khan%'
	and  
	release_year >= Extract(year from current_date) - 10
	
-- Q14 Find the top 10 actors who have appeared in the highest number of movies produced in India.

select 
	unnest(string_to_array(casts , ',')),
	count(*) as total_count
from netflix_data
where country ilike '%India%'
group by 1
order by 2 DESC
limit 10

-- Q15 Find the percentage of Movies vs TV Shows
select  
	type,
	round(
	count(*)::numeric / (select count(*) from netflix_data)::numeric *100 , 2) as percentage
from netflix_data
group by 1


-- Q16  Which countries release the most content per year?

select 
	release_year,
	unnest(string_to_array(country , ',')) as country,
	count(*)
from netflix_data
group by 1,2
order by  3 desc
limit 1



-- Q17 Find titles added during the holiday season

select * from netflix_data

select 

	to_char(to_date(date_added , 'Month DD , YYYY') , 'Month') as Month_name,
	*
from netflix_data
where  to_char(to_date(date_added , 'Month DD , YYYY') , 'Month') ilike '%November%' or 
		to_char(to_date(date_added , 'Month DD , YYYY') , 'Month') ilike '%December%'


-- Q18 Ranking countries by total number of TV Shows/Movies using


select 

	country,
	count(*) as total_content,
	rank() OVER(order by count(*) desc) as rank

from netflix_data
where country is not null
group by 1


-- Q19 Calculate percentage of TV Shows vs Movies added each year

WITH yearly_count AS (
  SELECT 
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) AS year_added,
    type,
    COUNT(*) AS count_type
  FROM netflix_data
  WHERE date_added IS NOT NULL
  GROUP BY year_added, type
),
total_per_year AS (
  SELECT year_added, SUM(count_type) AS total
  FROM yearly_count
  GROUP BY year_added
)
SELECT 
  y.year_added,
  y.type,
  y.count_type,
  ROUND((y.count_type * 100.0) / t.total, 2) AS percentage
FROM yearly_count y
JOIN total_per_year t ON y.year_added = t.year_added
ORDER BY y.year_added, y.type desc



--Q20 Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--    the description field. Label content containing these keywords as 'Bad' and all other 
--     content as 'Good'. Count how many items fall into each category.

with new_table 
as
(
select *,
	CASE
	when 
		description ilike '%kills%' or
		description ilike '%violence%' then 'Bad_content'
		else 'Good_content'
	end category

from netflix_data

)
select 
	category,
	count(*) as total_count

from new_table
group by 1


