--NETFLIX PROJECT
DROP TABLE IF EXISTS Netflix;
CREATE TABLE Netflix (
	show_id	VARCHAR(6),
	type VARCHAR(10),
	title VARCHAR(110),
	director VARCHAR(220),
	casts VARCHAR(1000),
	country VARCHAR(150),
	date_added VARCHAR(50),
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(15),
	listed_in VARCHAR(100),
	description VARCHAR(250)
);

--Adding Data to table
COPY netflix(show_id, type, title, director, casts, country, date_added, release_year, rating, duration, listed_in, description)
FROM 'C:/netflix_titles.csv'
WITH (
    FORMAT csv,
    HEADER true,
    DELIMITER ','
);

SELECT * FROM Netflix

SELECT COUNT(*)
AS Total_content
from Netflix


SELECT Distinct(type)
AS Type
from Netflix

--15 Business Problems
	
--1. Count the number of Movies vs TV Shows.
SELECT TYPE,COUNT(*) AS MOVIE_COUNT
	FROM netflix
	GROUP BY TYPE

	
--2. Find the most common rating for movies and TV shows.
select TYPE,
	rating,
	RATING_COUNT
	from(
SELECT TYPE,
	rating,
	COUNT(RATING) AS RATING_COUNT,
	RANK() over (partition by type order by COUNT(*) desc ) as ranking 
	FROM NETFLIX	
	GROUP BY 1,2) as t1
where ranking = 1;
	

--3. List all movies released in a specific year(e.g., 2020)
select * from NETFLIX	
	where release_year = 2020 and type = 'Movie'
	
	
--4. Find the top 5 countries with the most content on Netflix
select trim(UNNEST(
	(STRING_TO_ARRAY(country,',')))) AS new_country,
	count(show_id)
	from NETFLIX	
	group by 1
	order by 2 desc
	limit 5
	
	
--5. Identify the longest movie
	
select * from netflix
	where type = 'Movie'
	AND
	duration = (select MAX(duration) from netflix)

	
--6. Find content added in the last 5 years
select * from NETFLIX	
	where To_date(date_added,'Month DD,YYYY')>= current_date - interval '5years'

	
--7. Find all the movies/TV shows by director 'Rajiv Chilaka'
select * from netflix
	where director  Ilike '%Rajiv Chilaka%'

--8. List all TV shows with more than 5 seasons
select *
	from netflix 
	where type = 'TV Show' 
	AND
	split_part(duration,' ',1)::numeric > 5

	
--9. Count the number of content items in each genre
select 
	Unnest(STRING_TO_ARRAY(listed_in,',')) as genre ,
	COUNT(show_id) as Total_content
	from netflix 
	GROUP BY 1

	
--10.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!

select 
    extract(year from To_date(date_added,'Month DD,YYYY'))as year,
	count(*) as Total_content,
	CAST(count(*)::numeric /(select count(*)from netflix where country = 'India')::numeric * 100
	as decimal(10,2)) as avg_content_per_year
from netflix
where country = 'India'
group by 1
order by 3 desc
limit 5
	
--11. List all movies that are documentaries
select * from netflix
where listed_in Ilike '%Documentaries%' and type = 'Movie'

--12. Find all content without a director
select * from netflix
where director is NULL

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
select * from netflix
where casts ilike '%Salman Khan%' AND release_year > extract(year from current_date) - 10


--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
select 
	unnest(string_to_array(casts,',')) as actors,
	count(*)
	from netflix
where country ilike '%India%'
group by 1 
order by 2 desc
limit 10

--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.
With new_table 
AS(
select *,
case
	when description ilike '% kill %' OR
	description ilike '% violence %' Then 'Bad_content'
	else 'Good_content'
end Category
	from netflix
) 
select category , count(*) as total_content
from new_table
group by 1
	







