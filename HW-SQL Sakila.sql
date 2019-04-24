-- 1a- Display the first and last name of all actors from the table actor
USE sakila;
SELECT first_name, last_name
FROM actor;

-- 1b- Display the first and last name in a single column in upper case letters.  Name the column actor name
SELECT concat(first_name, ' ', last_name) AS 'Actor Name'
FROM actor;

-- 2a Find the ID number, first name and last name of an actor where the first name is "Joe"
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name="Joe";

-- 2b Find all actors whose last names contain the letters GEN
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c Find all actors whose last names contain the letters LI and order by last name and first name
SELECT last_name, first_name
FROM actor
WHERE last_name LIKE '%LI%';

-- 2d Using In, display the country_id and country columns of the following countries:Afghanistan, Bangladesh and China
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a Add 'description' column for each actor using data type blob, 
ALTER TABLE actor
	ADD COLUMN description BLOB;
    
SELECT * FROM actor;

-- 3b Add 'description' column for each actor using data type blob, 
ALTER TABLE actor
	DROP COLUMN description;     
    
SELECT * FROM actor;

-- 4a List the names of the actors and how many actors have that last name
SELECT COUNT(last_name), last_name
FROM actor
GROUP BY last_name;

-- 4b List last names of actors and the number of actors who have that last name but only if last name 
-- is shared by two actors

SELECT COUNT(last_name), last_name
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) > 2;

-- 4c Correct HARPO WILLIAMS entered in as GROUCHO WILLIAMS 

UPDATE actor
SET first_name="HARPO", last_name="WILLIAMS"
WHERE first_name="GROUCHO";

SELECT first_name, last_name
FROM actor
WHERE first_name="HARPO";

-- 4d use one line of command to change HARPO back to GROUCHO

UPDATE actor 
SET first_name="GROUCHO" 
WHERE first_name="HARPO";

SELECT first_name, last_name
FROM actor
WHERE first_name="GROUCHO";

-- 5A locate the schema of the address table
SHOW CREATE TABLE address;

-- I copied from table which was created from command above
-- CREATE TABLE `address` (
  -- `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
   -- `address` varchar(50) NOT NULL,
   -- `address2` varchar(50) DEFAULT NULL,
   -- `district` varchar(20) NOT NULL,
  --  `city_id` smallint(5) unsigned NOT NULL,
   -- `postal_code` varchar(10) DEFAULT NULL,
  --  `phone` varchar(20) NOT NULL,
   -- `location` geometry NOT NULL,
   -- `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
   -- PRIMARY KEY (`address_id`),
   -- KEY `idx_fk_city_id` (`city_id`),
   -- SPATIAL KEY `idx_location` (`location`),
   -- CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
 -- ) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8
 
 -- 6a JOIN the staff and address tables to display the first and last name and address of each staff member
 SELECT staff.first_name, staff.last_name, address.address
 FROM staff
 JOIN	address
 ON staff.address_id = address.address_id;
 
 -- 6b Join staff and payment tables to display the total amount rung up by each staff member in August of 2005
 SELECT staff.first_name, staff.last_name, SUM(payment.amount) AS "total amount rung up"
 FROM staff
 JOIN payment
 ON staff.staff_id = payment.staff_id
 WHERE payment_date BETWEEN'2005-08-01%' AND '2005-08-30%'
 GROUP BY staff.last_name;
 
 -- 6c Use inner join to display each film and the number of actors wo are listed in the film, use film_actor and film tables
 SELECT film.title, SUM(film_actor.actor_id) AS "Number of actors in film"
 FROM film
 INNER JOIN film_actor
 ON film.film_id = film_actor.film_id
 GROUP BY film.title;
 
 -- 6d How maany copies of the film Hunchback Impossible exist in the inventory system
 SELECT film.title, COUNT(inventory.film_id) AS "Total copies in inventory"
 FROM film
 JOIN inventory
 ON film.film_id = inventory.film_id
 WHERE film.title='HUNCHBACK IMPOSSIBLE';

 
 -- 6e List total paid by each customer using the payment and customer tables and JOIN COMMAND
 SELECT customer.first_name, customer.last_name, SUM(payment.amount) AS "Total Paid by Customer"
 FROM customer
 JOIN payment
 ON customer.customer_id = payment.customer_id
 GROUP BY customer.last_name;

-- 7a Display the titles of movies starting with letters K and Q and are in English
SELECT title, language_id 
FROM filmfilm
WHERE title LIKE 'Q%' or title LIKE 'K%' = ANY
    (
     SELECT language_id
     FROM language
     WHERE language_id=1
    );
   
   -- 7b Use subqueries to display all actors in the film Alone Trip 
SELECT first_name, last_name
FROM actor                    
WHERE actor_id IN
 (
  SELECT actor_id
  FROM film_actor
  WHERE film_id IN
  (
   SELECT film_id
   FROM film
   WHERE title="Alone Trip"
    )
   );
   
   
   -- 7c - Use joins to find the names and addresses of all Canadian customers   
SELECT customer.first_name, customer.last_name, address.address, address.district, address.postal_code
FROM customer
	LEFT JOIN address
		ON customer.address_id = address.address_id
	LEFT JOIN city
		ON address.city_id=city.city_id
	LEFT JOIN country
		ON city.country_id=country.country_id
WHERE country.country_id=20;   
   
  -- 7D Identify all movies categorized as family films
  SELECT film.title AS "Family Movies"
  FROM film 
  WHERE film_id IN
  (
  SELECT film_id
  FROM film_category
  WHERE category_id IN
  (SELECT category_id
  FROM category
  WHERE name="Family")
  ); 
  
  --  7E display the most frequently rented movies in desc order
  SELECT title AS "Movies with Most Days Rented"
  FROM film
  ORDER BY rental_duration DESC
  LIMIT 10;
   
-- 7f write a query to display how much business, in dollars, each store brought in.
SELECT staff.store_id, SUM(payment.amount) AS "Revenue $'s" 
FROM staff
JOIN payment
ON staff.staff_id=payment.staff_id
GROUP BY staff.store_id;

-- 7g  Display each stores Store ID, city and country
SELECT store.store_id, city.city, country.country
FROM store
	JOIN address
		ON store.address_id=address.address_id
	JOIN city
		ON address.city_id=city.city_id
	JOIN country
		ON city.country_id=country.country_id;
        
-- 7h Top 5 genre in gross revenue in descending order
SELECT category.name AS "Genre", SUM(payment.amount) AS "Gross Revenue"
FROM category
	JOIN film_category
		ON category.category_id=film_category.category_id
	JOIN inventory
		ON film_category.film_id=inventory.film_id
	JOIN rental
		ON inventory.inventory_id=rental.inventory_id
	JOIN payment
		ON rental.rental_id=payment.rental_id
	GROUP BY category.name 
    ORDER BY SUM(payment.amount) DESC;


-- 8a Create a view for Top Five genres by gross revenue, note I made a change to the view to change name to Genre
-- the view wouldn't update so I found the CREATE OR REPLACE command on W3 Schools        
CREATE OR REPLACE VIEW top_five_gross_rev_genre AS 

SELECT category.name AS "Genre", SUM(payment.amount) AS "Gross Revenue"
FROM category
	JOIN film_category
		ON category.category_id=film_category.category_id
	JOIN inventory
		ON film_category.film_id=inventory.film_id
	JOIN rental
		ON inventory.inventory_id=rental.inventory_id
	JOIN payment
		ON rental.rental_id=payment.rental_id
	GROUP BY category.name 
    ORDER BY SUM(payment.amount) DESC
    LIMIT 5;
               
-- 8b - display the newly created view
SELECT * FROM top_five_gross_rev_genre;
 
-- 8c - Delete the view created in 8a
DROP VIEW top_five_gross_rev_genre;

 


   
   
   
    
	

 
 
 
 
 

 
 
 






