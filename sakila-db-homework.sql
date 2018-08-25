USE sakila;

-- 1a. Display the first and last names of all actors from the table actor.
SELECT 
	first_name,
    last_name
FROM
	actor;
    
-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT 
	concat(first_name, ' ', last_name) as 'Actor Name'
FROM
	actor;
    
-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe."
-- What is one query would you use to obtain this information?
SELECT 
	actor_id,
	first_name,
    last_name
FROM
	actor
WHERE 
	first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT 
	actor_id,
	first_name,
    last_name
FROM
	actor
WHERE 
	last_name like '%GEN%';
    
-- 2c. Find all actors whose last names contain the letters LI.
-- This time, order the rows by last name and first name, in that order:
SELECT 
	actor_id,
	first_name,
    last_name
FROM
	actor
WHERE 
	last_name like '%LI%'
ORDER BY
	last_name, first_name;
    
-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT 
	country_id,
    country
FROM country
WHERE country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor.
-- You don't think you will be performing queries on a description,
-- so create a column in the table actor named description and use the data type BLOB
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor ADD COLUMN description BLOB;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort.
-- Delete the description column.
ALTER TABLE actor drop column description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT 
	last_name,
    count(last_name)
FROM 
	actor
GROUP BY
	last_name
ORDER BY
	count(last_name) DESC;

-- 4b. List last names of actors and the number of actors who have that last name,
-- but only for names that are shared by at least two actors
SELECT 
	last_name,
    count(last_name)
FROM 
	actor
GROUP BY
	last_name
HAVING
	count(last_name) >= 2
ORDER BY
	count(last_name) DESC;
    
-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS.
-- Write a query to fix the record.
UPDATE 
	actor
SET first_name = 'Harpo'
WHERE
	first_name = 'Groucho'
    AND last_name = 'Williams';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO.
-- It turns out that GROUCHO was the correct name after all!
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
SET SQL_SAFE_UPDATES = 0;

UPDATE
	actor
SET first_name = 'Groucho'
WHERE 
	first_name = 'Harpo';

SET SQL_SAFE_UPDATES = 1;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
SHOW CREATE TABLE address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member.
-- Use the tables staff and address:
SELECT
	s.first_name,
    s.last_name,
    a.*
FROM staff s
JOIN address a USING (address_id);

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005.
-- Use tables staff and payment.
SELECT
	s.first_name,
    s.last_name,
    sum(p.amount)
FROM staff s
JOIN payment p USING (staff_id)
WHERE 
	p.payment_date >= '2005-08-01'
    AND p.payment_date <= '2005-08-31'
GROUP BY s.first_name, s.last_name;

-- 6c. List each film and the number of actors who are listed for that film.
-- Use tables film_actor and film. Use inner join.
SELECT
	f.title,
    count(f.title) as 'Actor count'
FROM actor a
JOIN film_actor fa USING (actor_id)
JOIN film f USING(film_id)
GROUP BY f.title
ORDER BY count(f.title) DESC;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT 
	f.title,
    count(f.title) as copies
FROM film f
JOIN inventory i USING(film_id)
WHERE f.title = 'Hunchback Impossible'
GROUP BY f.title;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer.
-- List the customers alphabetically by last name:
-- ![Total amount paid](Images/total_payment.png)
SELECT
	c.first_name,
    c.last_name,
    sum(p.amount) as 'Total Amount Paid'
FROM customer c
JOIN payment p USING(customer_id)
GROUP BY c.first_name, c.last_name
ORDER BY c.last_name; 

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence.
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT 
	title
FROM film
WHERE film_id in 
	(SELECT film_id from film where title like 'K%' OR title like 'Q%');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT 
	first_name,
    last_name,
    last_update
FROM actor
WHERE actor_id in (
	SELECT actor_id
	FROM film_actor
	WHERE film_id in (
		SELECT film_id 
		FROM film
		WHERE title = 'Alone Trip'
	)
);
	
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers.
-- Use joins to retrieve this information.
SELECT
	c.first_name,
    c.last_name,
    c.email
FROM customer c
JOIN address a USING(address_id)
JOIN city ci USING(city_id)
JOIN country co USING(country_id)
WHERE co.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion.
-- Identify all movies categorized as family films.
SELECT 
	f.title
FROM film f
JOIN film_category fc USING(film_id)
WHERE fc.category_id in (
    SELECT category_id
    FROM category
	WHERE name = 'Family'
);
     
-- 7e. Display the most frequently rented movies in descending order.
SELECT
	f.title,
    count(*) AS total_rental_count
FROM rental r
JOIN inventory i USING(inventory_id)
JOIN film f USING (film_id)
GROUP BY f.title
ORDER BY total_rental_count DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT
	s.store_id,
    SUM(p.amount) AS total_amount
FROM store s
JOIN staff st USING (store_id)
JOIN payment p USING (staff_id)
GROUP BY s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT
	s.store_id,
    c.city,
    co.country
FROM store s
JOIN address a USING(address_id)
JOIN city c USING(city_id)
JOIN country co USING(country_id);

-- 7h. List the top five genres in gross revenue in descending order.
-- (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT
	c.name as 'Film Genres',
    SUM(p.amount) As 'Total Revenue'
FROM category c
JOIN film_category fc USING (category_id)
JOIN inventory i USING (film_id)
JOIN rental r USING (inventory_id)
JOIN payment p USING(rental_id)
GROUP BY c.name
ORDER BY 'Total Revenue'
LIMIT 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue.
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE OR REPLACE VIEW top_five_genres AS
SELECT
	c.name as 'Film Genres',
    SUM(p.amount) As 'Total Revenue'
FROM category c
JOIN film_category fc USING (category_id)
JOIN inventory i USING (film_id)
JOIN rental r USING (inventory_id)
JOIN payment p USING(rental_id)
GROUP BY c.name
ORDER BY 'Total Revenue'
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;
DESCRIBE top_five_genres;
SHOW CREATE VIEW top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW IF EXISTS top_five_genres;