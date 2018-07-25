use Sakila;
-- 1a. first and last names of all actors from the table actor 
select first_name, last_name from actor; 

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT concat(first_name," ", last_name) AS Actor_Name
FROM actor;

-- 2a. find ID number, first name, last name of actor. First name is "Joe" 
-- what kind of query can you use for this?
SELECT actor_id, first_name, last_name 
FROM actor 
WHERE first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters GEN 
SELECT last_name
FROM actor 
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last name contains the letters LI, order by last name/first name
SELECT last_name, first_name
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- 2d. Use IN to display country_id and country columns for Afghanistan, Bangladesh, China 
SELECT country_id, country 
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add column MIDDLE NAME to table actor, place between first name and last name, 
-- specify data type to make it work 
ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(85) AFTER first_name; 

ALTER TABLE actor DROP middle_name;

ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(85) AFTER first_name; 

-- 3b. last names too long, change data type of middle name column to BLOB 
ALTER TABLE actor MODIFY middle_name BLOB; 

-- 3c. Delete middle name column 
ALTER TABLE actor DROP middle_name; 

-- 4a. list last names of actors, also how many actor have that last name 
SELECT last_name, COUNT(last_name) AS "last_name_counts"
FROM actor 
GROUP BY last_name; 

-- 4b. list last names of actors and number of actors that have that same last name 
-- BUT only for names that are shared by AT LEAST 2 actors 
SELECT last_name, count(last_name) AS "last_name_counts"
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) >= 2; 

-- 4c. .GROUCHO WILLIAMS should be HARPO WILLIAMS in actor table. FIX. 
-- https://www.w3schools.com/sql/sql_update.asp
UPDATE actor 
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';
-- SELECT first_name, last_name
-- FROM actor 
-- WHERE first_name = "HARPO"

-- 4d. --HARPO WILLIAMS actor id is 172
-- SELECT first_name, last_name, actor_id
-- FROM actor 
-- WHERE first_name = "HARPO"
UPDATE actor 
SET first_name = 
CASE WHEN first_name = 'HARPO'
THEN 'GROUCHO'
ELSE 'MUCHO GROUCHO'
END 
WHERE actor_id = 172; 

-- 5a. WHAT query for recreating schema of address table
SHOW CREATE TABLE sakila.address;
-- CREATE TABLE `address` (
--   `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
--   `address` varchar(50) NOT NULL,
--   `address2` varchar(50) DEFAULT NULL,
--   `district` varchar(20) NOT NULL,
--   `city_id` smallint(5) unsigned NOT NULL,
--   `postal_code` varchar(10) DEFAULT NULL,
--   `phone` varchar(20) NOT NULL,
--   `location` geometry NOT NULL,
--   `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
--   PRIMARY KEY (`address_id`),
--   KEY `idx_fk_city_id` (`city_id`),
--   SPATIAL KEY `idx_location` (`location`),
--   CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
-- ) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8

-- 6a. use join to display first and last names, address, of each staff member use tables
-- staff and address 
SELECT first_name, last_name 
from staff s 
join address a 
on s.address_id = a.address_id;

-- 6b. use join to display total rung up by each staff member in 2005 use tables 
-- staff and payment 
SELECT first_name, last_name, SUM(amount)
FROM staff s 
JOIN payment p 
on s.staff_id = p.staff_id 
GROUP by p.staff_id 
ORDER by 2 DESC; 

-- 6c. list each film and number of actors in that film, use tables film_actor and film use inner join 
SELECT title, COUNT(actor_id) 
FROM film f 
JOIN film_actor fa 
on f.film_id = fa.film_id 
GROUP BY title;

-- 6d. How many copies of the movie Hunchback Impossible exist in inventory?
SELECT title, COUNT(inventory_id)
FROM film f 
JOIN inventory i  
ON f.film_id = i.film_id 
WHERE title = "Hunchback Impossible"; 

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically 
-- by last name:
SELECT last_name, first_name, SUM(amount)
FROM payment p
INNER JOIN customer c
ON p.customer_id = c.customer_id
GROUP BY p.customer_id
ORDER BY last_name ASC;

-- 7a. Use subqueries to display the titles of movies starting with the letters K and Q whose 
-- language is English. 

SELECT title FROM film
WHERE language_id in
	(SELECT language_id 
	FROM language
	WHERE name = "English" )
AND (title LIKE "K%") OR (title LIKE "Q%");

-- 7b. Use subqueries to display all actors that appear in Alone Trip 
SELECT last_name, first_name
FROM actor
WHERE actor_id in
	(SELECT actor_id FROM film_actor
	WHERE film_id in 
		(SELECT film_id FROM film
		WHERE title = "Alone Trip"));

-- 7c. names and email addresses of all canadian customers 

SELECT country, last_name, first_name, email
FROM country c
LEFT JOIN customer cu
ON c.country_id = cu.customer_id
WHERE country = 'Canada';

-- 7d. Identify all movies categorized as family films
SELECT title, category
FROM film_list
WHERE category = 'Family';

-- 7e. Display the most frequently rented movies in descending order.

SELECT i.film_id, f.title, COUNT(r.inventory_id)
FROM inventory i
INNER JOIN rental r
ON i.inventory_id = r.inventory_id
INNER JOIN film_text f 
ON i.film_id = f.film_id
GROUP BY r.inventory_id
ORDER BY COUNT(r.inventory_id) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT store.store_id, SUM(amount)
FROM store
INNER JOIN staff
ON store.store_id = staff.store_id
INNER JOIN payment p 
ON p.staff_id = staff.staff_id
GROUP BY store.store_id
ORDER BY SUM(amount);

-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT store_id, city, country FROM store s
JOIN address a ON (s.address_id=a.address_id)
JOIN city c ON (a.city_id=c.city_id)
JOIN country cntry ON (c.country_id=cntry.country_id);

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following 
-- tables: category, film_category, inventory, payment, and rental.)

SELECT c.name AS "Top Five", SUM(p.amount) AS "Gross" 
FROM category c
JOIN film_category fc ON (c.category_id=fc.category_id)
JOIN inventory i ON (fc.film_id=i.film_id)
JOIN rental r ON (i.inventory_id=r.inventory_id)
JOIN payment p ON (r.rental_id=p.rental_id)
GROUP BY c.name ORDER BY Gross  LIMIT 5;


-- 8a. In your new role as an executive, you would like to have an easy way of 
-- viewing the top five genres by gross revenue. Use the solution from the 
-- problem above to create a view. If you haven't solved 7h, you can substitute 
-- another query to create a view.


CREATE VIEW top_five_grossing_genres AS

SELECT name, SUM(p.amount)
FROM category c
INNER JOIN film_category fc
INNER JOIN inventory i
ON i.film_id = fc.film_id
INNER JOIN rental r
ON r.inventory_id = i.inventory_id
INNER JOIN payment p
GROUP BY name
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?

SELECT * FROM top_five_grossing_genres;

-- 8c. You find that you no longer need the view top_five_genres. 
-- Write a query to delete it.

DROP VIEW top_five_grossing_genres;




