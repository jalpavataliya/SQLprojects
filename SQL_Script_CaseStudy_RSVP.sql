USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/

-- Segment 1:


-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:
SELECT table_name,
       table_rows
FROM   information_schema.tables
WHERE  table_schema = 'imdb'
ORDER  BY table_name; 


-- Q2. Which columns in the movie table have null values?
-- Type your code below:
SELECT 'col_id' col_name,
       Count(*) nulls_count
FROM   movie
WHERE  id IS NULL -- 0
UNION
SELECT 'col_title' col_name,
       Count(*)    nulls_count
FROM   movie
WHERE  title IS NULL -- 0
UNION
SELECT 'col_year' col_name,
       Count(*)   nulls_count
FROM   movie
WHERE  year IS NULL -- 0
UNION
SELECT 'col_date_published' col_name,
       Count(*)             nulls_count
FROM   movie
WHERE  date_published IS NULL -- 0
UNION
SELECT 'col_duration' col_name,
       Count(*)       nulls_count
FROM   movie
WHERE  duration IS NULL -- 0
UNION
SELECT 'col_country' col_name,
       Count(*)      nulls_count
FROM   movie
WHERE  country IS NULL -- 20
UNION
SELECT 'col_worlwide_gross_income' col_name,
       Count(*)                    nulls_count
FROM   movie
WHERE  worlwide_gross_income IS NULL -- 3724
UNION
SELECT 'col_languages' col_name,
       Count(*)        nulls_count
FROM   movie
WHERE  languages IS NULL -- 194
UNION
SELECT 'col_production_company' col_name,
       Count(*)                 nulls_count
FROM   movie
WHERE  production_company IS NULL -- 528
; 
-- country, worlwide_gross_income, languages, production_company are the columns with null values in the movie table

-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 


-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)
/* Output format for the first part:
+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+
Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- First part:
SELECT year,
       Count(*) number_of_movies
FROM   movie
GROUP  BY year; 

-- Second part:
SELECT Month(date_published) month_num,
       Count(*)              number_of_movies
FROM   movie
GROUP  BY Month(date_published)
ORDER  BY month_num; 

/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/


-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:
SELECT Count(*) number_of_movies
FROM   movie
WHERE  country IN ( 'India', 'USA' )
       AND year = 2019;

/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/


-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:
SELECT genre
FROM   genre
GROUP  BY genre
ORDER  BY genre;

/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */


-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:
SELECT genre,
       Count(*) movie_count
FROM   genre AS genre
       INNER JOIN movie AS movie
               ON genre.movie_id = movie.id
GROUP  BY genre
ORDER  BY movie_count DESC
LIMIT  1;


/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/


-- Q7. How many movies belong to only one genre?
-- Type your code below:
SELECT Count(*) movie_count
FROM   (SELECT id,
               title,
               Count(*) genre_count
        FROM   (SELECT DISTINCT id,
                                title,
                                genre
                FROM   genre AS genre
                       INNER JOIN movie AS movie
                               ON genre.movie_id = movie.id) movie_genre
        GROUP  BY id,
                  title
        HAVING Count(*) = 1) A;

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/


-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)
/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT genre.genre,
       Round(Sum(movie.duration) / Count(DISTINCT movie.id)) avg_duration
FROM   movie AS movie
       INNER JOIN genre AS genre
               ON movie.id = genre.movie_id
GROUP  BY genre.genre
ORDER  BY avg_duration DESC;

/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/


-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)
/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
SELECT genre.genre,
       Count(DISTINCT movie.id)                    movie_count,
       Rank()
         OVER (
           ORDER BY Count(DISTINCT movie.id) DESC) genre_rank
FROM   movie AS movie
       INNER JOIN genre AS genre
               ON movie.id = genre.movie_id
GROUP  BY genre.genre;

/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/



-- Segment 2:

-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:
SELECT Min(avg_rating)    min_avg_rating,
       Max(avg_rating)    max_avg_rating,
       Min(total_votes)   min_total_votes,
       Max(total_votes)   max_total_votes,
       Min(median_rating) min_median_rating,
       Max(median_rating) max_median_rating
FROM   ratings;

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/


-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too
SELECT     movie.title,
           avg_rating,
           Dense_rank() over (ORDER BY avg_rating DESC) movie_rank
FROM       ratings ratings
INNER JOIN movie movie
ON         ratings.movie_id = movie.id
LIMIT      10;

/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/


-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:
+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have
SELECT ratings.median_rating,
       Count(movie.id) movie_count
FROM   ratings ratings
       INNER JOIN movie movie
               ON ratings.movie_id = movie.id
GROUP  BY ratings.median_rating
ORDER  BY ratings.median_rating;

/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/


-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:
SELECT *
FROM   (SELECT movie.production_company,
               Count(movie.id)                    movie_count,
               Dense_rank()
                 OVER (
                   ORDER BY Count(movie.id) DESC) prod_company_rank
        FROM   ratings ratings
               INNER JOIN movie movie
                       ON ratings.movie_id = movie.id
        WHERE  ratings.avg_rating > 8
               AND movie.production_company IS NOT NULL
        GROUP  BY movie.production_company) sub_query
WHERE  prod_company_rank = 1;

-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both


-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:
+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT genre.genre,
       Count(movie.id) movie_count
FROM   movie movie
       INNER JOIN genre genre
               ON movie.id = genre.movie_id
       INNER JOIN ratings ratings
               ON movie.id = ratings.movie_id
WHERE  movie.year = 2017
       AND Month(movie.date_published) = 3
       AND movie.country = 'USA'
       AND total_votes > 1000
GROUP  BY genre.genre
ORDER  BY movie_count DESC;

-- Lets try to analyse with a unique problem statement.


-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
SELECT movie.title,
       ratings.avg_rating,
       genre.genre
FROM   movie movie
       INNER JOIN genre genre
               ON movie.id = genre.movie_id
       INNER JOIN ratings ratings
               ON movie.id = ratings.movie_id
WHERE  movie.title LIKE 'The%'
       AND ratings.avg_rating > 8
ORDER  BY ratings.avg_rating DESC;

-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.


-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:
SELECT Count(*) movie_count
FROM   movie movie
       INNER JOIN ratings ratings
               ON movie.id = ratings.movie_id
WHERE  ratings.median_rating = 8
       AND movie.date_published BETWEEN '2018-04-01' AND '2019-04-01';

-- Once again, try to solve the problem given below.


-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:
SELECT 'German'         language,
       Sum(total_votes) total_votes
FROM   movie movie
       JOIN ratings ratings
         ON movie.id = ratings.movie_id
WHERE  Lower(movie.languages) LIKE '%german%'
UNION
SELECT 'Italian'        language,
       Sum(total_votes) total_votes
FROM   movie movie
       JOIN ratings ratings
         ON movie.id = ratings.movie_id
WHERE  Lower(movie.languages) LIKE '%italian%';

-- Answer is Yes
/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/



-- Segment 3:

-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:
SELECT Count(*) - Count(name)             name_nulls,
       Count(*) - Count(height)           height_nulls,
       Count(*) - Count(date_of_birth)    date_of_birth_nulls,
       Count(*) - Count(known_for_movies) known_for_movies_nulls
FROM   names;

/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:
+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
WITH top_three_genres
AS
  (
                  SELECT DISTINCT genre
                  FROM            (
                                             SELECT     genre.genre,
                                                        count(movie.id)                                   movie_count,
                                                        dense_rank() over (ORDER BY count(movie.id) DESC) movie_rank
                                             FROM       movie movie
                                             INNER JOIN genre genre
                                             ON         movie.id = genre.movie_id
                                             INNER JOIN ratings ratings
                                             ON         movie.id = ratings.movie_id
                                             WHERE      ratings.avg_rating > 8
                                             GROUP BY   genre.genre
                                             LIMIT      3) sub_query )
  SELECT director_name
  FROM   (
                    SELECT     nm.name                                                    director_name,
                               count(DISTINCT movie.id)                                   movie_count,
                               dense_rank() over (ORDER BY count(DISTINCT movie.id) DESC) director_rank
                    FROM       movie movie
                    INNER JOIN genre genre
                    ON         movie.id = genre.movie_id
                    INNER JOIN top_three_genres top_three_genres
                    ON         genre.genre = top_three_genres.genre
                    INNER JOIN ratings ratings
                    ON         ratings.movie_id = movie.id
                    INNER JOIN director_mapping dir_map
                    ON         movie.id = dir_map.movie_id
                    INNER JOIN names nm
                    ON         nm.id = dir_map.name_id
                    WHERE      ratings.avg_rating > 8
                    GROUP BY   nm.name) sub_query
  LIMIT  3;

/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/


-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT   names.name                                                 actor_name,
         Count(DISTINCT movie.id)                                   movie_count,
         Dense_rank() over (ORDER BY count(DISTINCT movie.id) DESC) actor_rank
FROM     movie movie
JOIN     ratings ratings
ON       movie.id = ratings.movie_id
JOIN     role_mapping role_map
ON       movie.id = role_map.movie_id
JOIN     names names
ON       role_map.name_id = names.id
WHERE    ratings.median_rating >= 8
AND      role_map.category = 'actor'
GROUP BY names.name
LIMIT    2;

/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/


-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
SELECT   movie.production_company,
         Sum(ratings.total_votes)                                   vote_count,
         Dense_rank() over (ORDER BY sum(ratings.total_votes) DESC) prod_comp_rank
FROM     movie movie
JOIN     ratings ratings
ON       movie.id = ratings.movie_id
WHERE    movie.production_company IS NOT NULL
GROUP BY movie.production_company
LIMIT    3;

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/


-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
SELECT   names.name                                                                                                 actor_name,
         Sum(ratings.total_votes)                                                                                   total_votes,
         Count(DISTINCT movie.id)                                                                                   movie_count,
         Round(Sum(ratings.avg_rating                       * ratings.total_votes) / Sum(ratings.total_votes), 2)   actor_avg_rating,
         Dense_rank() over (ORDER BY sum(ratings.avg_rating * ratings.total_votes) / sum(ratings.total_votes) DESC) actor_rank
FROM     movie movie
JOIN     ratings ratings
ON       movie.id = ratings.movie_id
JOIN     role_mapping role_map
ON       movie.id = role_map.movie_id
JOIN     names names
ON       role_map.name_id = names.id
WHERE    role_map.category = 'actor'
AND      movie.country = 'India'
GROUP BY names.name
HAVING   count(DISTINCT movie.id) >= 5
LIMIT    1;

-- Top actor is Vijay Sethupathi


-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
SELECT   names.name,
         Sum(total_votes)                                                                          total_votes,
         Count(DISTINCT movie.id)                                                                  AS movie_count,
         Round(Sum(avg_rating * total_votes)/Sum(total_votes),2)                                   AS actress_avg_rating,
         Dense_rank() over (ORDER BY round(sum(avg_rating * total_votes)/sum(total_votes),2) DESC) AS actress_rank
FROM     movie movie
JOIN     role_mapping role_map
ON       movie.id = role_map.movie_id
JOIN     names names
ON       role_map.name_id = names.id
JOIN     ratings ratings
ON       movie.id = ratings.movie_id
WHERE    lower(role_map.category) = "actress"
AND      lower(movie.languages) LIKE "%hindi%"
AND      lower(movie.country) = "india"
GROUP BY names.name
HAVING   count(DISTINCT movie.id) >=3
LIMIT    5;

/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:
SELECT movie.title, ratings.avg_rating,
       CASE
         WHEN ratings.avg_rating > 8 THEN 'Superhit'
         WHEN ratings.avg_rating BETWEEN 7 AND 8 THEN 'Hit'
         WHEN ratings.avg_rating BETWEEN 5 AND 7 THEN 'One-time-watch'
         ELSE 'Flop'
       end movie_type
FROM   movie movie
       JOIN genre genre
         ON movie.id = genre.movie_id
       JOIN ratings ratings
         ON movie.id = ratings.movie_id
WHERE  genre.genre = 'Thriller'
ORDER  BY ratings.avg_rating DESC; 

/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/



-- Segment 4:


-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:
SELECT genre,
       avg_duration,
       Round(Sum(Avg(avg_duration))
               OVER (
                 ORDER BY genre), 2) AS running_total_duration,
       Round(Avg(Avg(avg_duration))
               OVER (
                 ORDER BY genre), 2) AS moving_avg_duration
FROM   (SELECT genre.genre,
               Round(Avg(duration), 2) avg_duration
        FROM   movie movie
               JOIN genre genre
                 ON movie.id = genre.movie_id
        GROUP  BY genre.genre) sub_query
GROUP  BY genre,
          avg_duration;

-- Round is good to have and not a must have; Same thing applies to sorting
-- Let us find top 5 movies of each year with top 3 genres.


-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
-- Top 3 Genres based on most number of movies
WITH top_three_genres
AS
  (
                  SELECT DISTINCT genre
                  FROM            (
                                           SELECT   genre.genre,
                                                    count(movie.id)                                   movie_count,
                                                    dense_rank() over (ORDER BY count(movie.id) DESC) movie_rank
                                           FROM     movie movie
                                           JOIN     genre genre
                                           ON       movie.id = genre.movie_id
                                           GROUP BY genre.genre
                                           LIMIT    3) sub_query )
  SELECT *
  FROM   (
                  SELECT   genre.genre,
                           movie.year,
                           movie.title,
                           sum(movie.worlwide_gross_income)                                                           worlwide_gross_income,
                           dense_rank() over (partition BY movie.year ORDER BY sum(movie.worlwide_gross_income) DESC) movie_rank
                  FROM     (
                                  SELECT id,
                                         year,
                                         title,
                                         cast(coalesce(REPLACE(REPLACE(worlwide_gross_income, 'INR ', ''), '$ ', ''), '0') AS signed) worlwide_gross_income
                                  FROM   movie) movie
                  JOIN     genre genre
                  ON       movie.id = genre.movie_id
                  JOIN     top_three_genres top_three_genres
                  ON       genre.genre = top_three_genres.genre
                  GROUP BY genre.genre,
                           movie.year,
                           movie.title ) sub_query
  WHERE  movie_rank <= 5;

-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.


-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
SELECT   production_company,
         Count(movie.id)                            AS movie_count,
         Dense_rank() over(ORDER BY count(id) DESC)    prod_comp_rank
FROM     movie movie
JOIN     ratings ratings
ON       movie.id = ratings.movie_id
WHERE    ratings.median_rating >= 8
AND      movie.production_company IS NOT NULL
         -- and 1 = (case when languages like '%,%' then 1 else 0 end)
AND      position(',' IN languages) > 0
GROUP BY production_company
LIMIT    2;

-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
SELECT   names.name                                                 AS actress_name,
         Sum(total_votes)                                           AS total_votes,
         Count(DISTINCT movie.id)                                   AS movie_count,
         Round(Sum(avg_rating * total_votes)/Sum(total_votes), 2)   AS actress_avg_rating,
         Dense_rank() over (ORDER BY count(DISTINCT movie.id) DESC) AS actress_rank
FROM     movie movie
JOIN     genre genre
ON       genre.movie_id = movie.id
JOIN     ratings ratings
ON       ratings.movie_id = movie.id
JOIN     role_mapping role_map
ON       role_map.movie_id = movie.id
JOIN     names names
ON       names.id = role_map.name_id
WHERE    role_map.category="actress"
AND      ratings.avg_rating > 8
AND      genre.genre = "Drama"
GROUP BY names.name
LIMIT    3;



/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:
WITH dates
AS
  (
           SELECT   director_mapping.name_id director_id,
                    names.name               director_name,
                    director_mapping.movie_id,
                    movie.duration,
                    ratings.avg_rating,
                    ratings.total_votes,
                    movie.date_published,
                    lead(date_published, 1) over (partition BY director_mapping.name_id ORDER BY date_published, movie_id) next_date_published
           FROM     movie movie
           JOIN     director_mapping director_mapping
           ON       movie.id = director_mapping.movie_id
           JOIN     ratings ratings
           ON       ratings.movie_id = movie.id
           JOIN     names names
           ON       names.id = director_mapping.name_id ),
  top_director
AS
  (
         SELECT *,
                datediff(next_date_published, date_published) date_difference
         FROM   dates )
  SELECT   director_id,
           director_name,
           count(movie_id)                  number_of_movies,
           round(avg(date_difference),2) AS avg_inter_movie_days,
           round(avg(avg_rating),2)      AS avg_rating,
           sum(total_votes)              AS total_votes,
           min(avg_rating)               AS min_rating,
           max(avg_rating)               AS max_rating,
           sum(duration)                 AS total_duration
  FROM     top_director
  GROUP BY director_id
  ORDER BY number_of_movies DESC
  LIMIT    9;