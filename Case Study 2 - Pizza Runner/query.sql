-- Case Study 2 - Pizza Runner

-- Firstly, we need to investigate the data
-- Check data types in the customer_orders and runner_orders tables

-- TABLE 2: customer_orders
SELECT
  table_name,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_name = 'customer_orders';

   table_name    | column_name |          data_type
-----------------+-------------+-----------------------------
 customer_orders | order_id    | integer
 customer_orders | customer_id | integer
 customer_orders | pizza_id    | integer
 customer_orders | exclusions  | character varying
 customer_orders | extras      | character varying
 customer_orders | order_time  | timestamp without time ZONE

-- TABLE 3: runner_orders
SELECT
  table_name,
  column_name,
  data_type
FROM information_schema.columns
WHERE table_name = 'runner_orders';

  table_name   | column_name  |     data_type
---------------+--------------+-------------------
 runner_orders | order_id     | integer
 runner_orders | runner_id    | integer
 runner_orders | pickup_time  | character varying
 runner_orders | distance     | character varying
 runner_orders | duration     | character varying
 runner_orders | cancellation | character varying

-- Now, check for null values in the customer_orders and runner_orders tables

-- TABLE 2: customer_orders
-- We notice that there exists NULL values in the 'exclusions' and 'extras' columns
DROP TABLE IF EXISTS customer_orders_clean;
CREATE TABLE customer_orders_clean AS (
    SELECT
        order_id,
        customer_id,
        pizza_id,
        
        CASE
            WHEN exclusions = 'null' THEN NULL
            WHEN exclusions = '' THEN NULL
            ELSE exclusions
        END AS exclusions
        ,

        CASE
            WHEN extras = 'null' THEN NULL
            WHEN extras = '' THEN NULL
            WHEN extras = 'NaN' THEN NULL
            ELSE extras
        END as extras
        
        ,
        order_time
    FROM pizza_runner.customer_orders
);

-- TABLE 3: runner_orders
-- We notice that there exists NULL values in the 'pickup_time', 'distance', 'duration' and 'cancellation' columns
DROP TABLE IF EXISTS runner_orders_clean;
CREATE TABLE runner_orders_clean AS (
    SELECT
        order_id,
        runner_id,
        
        CASE
            WHEN pickup_time = 'null' THEN NULL
            ELSE pickup_time
        END as pickup_time

        ,
        -- NULLIF() returns NULL if two expressions are equal, otherwise it returns the first expression.
        -- Syntax for REGEXP_REPLACE(source, pattern, replacement_string,[, flags])
        -- 'g' instructs the function to remove all alphabets, not just the first one

        NULLIF(regexp_replace(distance, '[^0-9.]', '', 'g'), ''):: NUMERIC AS distance,
        NULLIF(regexp_replace(duration, '[^0-9.]', '', 'g'), ''):: NUMERIC AS duration,

        CASE
            WHEN cancellation IN ('null', 'NaN', '') THEN NULL
            ELSE cancellation
        END AS cancellation
    FROM pizza_runner.runner_orders
);


-- A. Pizza Metrics
-- 1. How many pizzas were ordered?
SELECT COUNT(*)
FROM pizza_runner.customer_orders;

 count
-------
    14


-- 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id)
FROM pizza_runner.customer_orders;

 count
-------
    10


-- 3. How many successful orders were delivered by each runner?
SELECT
    runner_id,
    COUNT(*) AS successful_orders
FROM runner_orders_clean
WHERE cancellation is NULL
GROUP BY runner_id
ORDER BY runner_id;

 runner_id | successful_orders
-----------+-------------------
         1 |                 4
         2 |                 3
         3 |                 1

-- 4. How many of each type of pizza was delivered?
SELECT
    pizza_name,
    COUNT(*)
FROM customer_orders_clean c
JOIN runner_orders_clean r ON (c.order_id = r.order_id)
JOIN pizza_runner.pizza_names p ON (c.pizza_id = p.pizza_id)
WHERE r.cancellation is NULL
GROUP BY pizza_name;

 pizza_name | count
------------+-------
 Meatlovers |     9
 Vegetarian |     3


-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT
    customer_id,
    SUM(
        CASE
            WHEN pizza_id = 1 THEN 1 ELSE 0
        END
    ) AS meatlovers,
    SUM(
        CASE
            WHEN pizza_id = 2 THEN 1 ELSE 0
        END
    ) AS vegetarian
FROM customer_orders_clean
GROUP BY customer_id
ORDER BY customer_id;

 customer_id | meatlovers | vegetarian
-------------+------------+------------
         101 |          2 |          1
         102 |          2 |          1
         103 |          3 |          1
         104 |          3 |          0
         105 |          0 |          1


-- 6. What was the maximum number of pizzas delivered in a single order?
SELECT
    order_id,
    COUNT(*) AS pizzas_ordered
FROM customer_orders_clean
GROUP BY order_id
ORDER BY pizzas_ordered DESC
LIMIT 1;

 order_id | pizzas_ordered
----------+----------------
        4 |              3


-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT
    customer_id,
    SUM(
        CASE
            WHEN exclusions IS NOT NULL THEN 1
            WHEN extras IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS changes_made,
    SUM(
        CASE
            WHEN exclusions IS NULL AND extras IS NULL THEN 1
            ELSE 0
        END
    ) AS no_changes
FROM customer_orders_clean
GROUP BY customer_id
ORDER BY customer_id;

 customer_id | changes_made | no_changes
-------------+--------------+------------
         101 |            0 |          3
         102 |            0 |          3
         103 |            4 |          0
         104 |            2 |          1
         105 |            1 |          0


-- 8. How many pizzas were delivered that had both exclusions and extras?
SELECT
    SUM(
        CASE
            WHEN c.exclusions IS NOT NULL AND c.extras IS NOT NULL THEN 1
            ELSE 0
        END
    ) AS exclusions_and_extras
FROM customer_orders_clean c
JOIN runner_orders_clean r ON (c.order_id = r.order_id)
WHERE r.cancellation IS NULL;

 exclusions_and_extras
-----------------------
                     1


-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT
    DATE_PART('hour', order_time) AS hour_of_day,
    COUNT(*) AS pizzas_ordered
FROM customer_orders_clean
GROUP BY hour_of_day
ORDER BY hour_of_day;

 hour_of_day | pizzas_ordered
-------------+----------------
          11 |              1
          13 |              3
          18 |              3
          19 |              1
          21 |              3
          23 |              3


-- 10. What was the volume of orders for each day of the week?
SELECT
    DATE_PART('dow', order_time) AS index,
    TO_CHAR(order_time, 'Dy') AS day_of_week,
    COUNT(*) AS pizzas_ordered
FROM customer_orders_clean
GROUP BY day_of_week, index
ORDER BY index;


-- B. Runner and Customer Experience
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

-- 4. What was the average distance travelled for each customer?

-- 5. What was the difference between the longest and shortest delivery times for all orders?

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

-- 7. What is the successful delivery percentage for each runner?




-- C. Ingredient Optimisation
-- 1. What are the standard ingredients for each pizza?

-- 2. What was the most commonly added extra?

-- 3. What was the most common exclusion?

-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
--      Meat Lovers
--      Meat Lovers - Exclude Beef
--      Meat Lovers - Extra Bacon
--      Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table
--    and add a 2x in front of any relevant ingredients
--      For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

-- D. Pricing and Ratings
-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza
--    Runner made so far if there are no delivery fees?

-- 2. What if there was an additional $1 charge for any pizza extras?
--      Add cheese is $1 extra

-- 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you
--    design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for
--    each successful customer order between 1 to 5.

-- 4. Using your newly generated table - can you join all of the information together to form a table which has the following information
--    for successful deliveries?
--      customer_id
--      order_id
--      runner_id
--      rating
--      order_time
--      pickup_time
--      Time between order and pickup
--      Delivery duration
--      Average speed
--      Total number of pizzas

-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre
--    traveled - how much money does Pizza Runner have left over after these deliveries?