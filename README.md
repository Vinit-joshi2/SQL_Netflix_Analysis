# Netflix Movies and TV Shows Data Analysis using SQL

  ![](https://github.com/Vinit-joshi2/SQL_Netflix_Analysis/blob/main/images.jpeg)

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
-- Netflix Project

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

```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT 
	type,
	COUNT(*)
FROM netflix_data
GROUP BY 1
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
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

```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT * 
FROM netflix_data
WHERE release_year = 2020 and type = 'Movie'

```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
select
	UNNEST(string_to_array(country , ',')) as new_county,
	count(show_id) as total_count

from netflix_data
group by 1
order by 2 desc
limit 5
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql

select * from netflix_data
where 
	type = 'Movie'
	and 
	duration = (select max(duration) from netflix_data)

```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
select * from netflix_data
where TO_DATE(date_added , 'Month , DD , YYYY') >= current_date - interval '5 years'

```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT *
FROM (
    SELECT 
        *,
        UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
    FROM netflix
) AS t
WHERE director_name = 'Rajiv Chilaka';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
select * from netflix_data
where 
	type = 'TV Show'
	and 
	SPLIT_PART(duration , ' '  ,1)::numeric  > 5 

```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
select 
	UNNEST(string_to_array(listed_in , ',')) as new_listed_in,
	count(show_id) as Total_conten
from netflix_data
group by 1

```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
select 
	extract(year from to_date(date_added , 'Month , DD , YYYY')) as year,
	count(*),
	round(
	count(*)::numeric / (select count(*) from netflix_data where country = 'India') ::numeric  * 100 , 2) as avg_content_per_year	
from netflix_data
where country = 'India'
group by 1

```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
select * from netflix_data
where listed_in ilike '%documentaries%'

```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
select * from netflix_data
where director is null

```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
select  * from netflix_data
where 
	casts ilike '%Salman Khan%'
	and  
	release_year >= Extract(year from current_date) - 10
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
select 
	unnest(string_to_array(casts , ',')),
	count(*) as total_count
from netflix_data
where country ilike '%India%'
group by 1
order by 2 DESC
limit 10
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Find the percentage of Movies vs TV Shows
``` sql
select  
	type,
	round(
	count(*)::numeric / (select count(*) from netflix_data)::numeric *100 , 2) as percentage
from netflix_data
group by 1

```

### 16. Which countries release the most content per year?
``` sql
select 
	release_year,
	unnest(string_to_array(country , ',')) as country,
	count(*)
from netflix_data
group by 1,2
order by  3 desc
limit 1
```

### 17. Find titles added during the holiday season

``` sql
select * from netflix_data

select 

	to_char(to_date(date_added , 'Month DD , YYYY') , 'Month') as Month_name,
	*
from netflix_data
where  to_char(to_date(date_added , 'Month DD , YYYY') , 'Month') ilike '%November%' or 
		to_char(to_date(date_added , 'Month DD , YYYY') , 'Month') ilike '%December%'
```


### 18. Ranking countries by total number of TV Shows/Movies using

``` sql
select 

	country,
	count(*) as total_content,
	rank() OVER(order by count(*) desc) as rank

from netflix_data
where country is not null
group by 1
```

### 19.Calculate percentage of TV Shows vs Movies added each year

``` sql
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
```


### 20. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
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

```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.


## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.


