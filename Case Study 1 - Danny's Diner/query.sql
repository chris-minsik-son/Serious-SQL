-- Case Study 1 - Danny's Diner Solutions

-- 1. What is the total amount each customer spent at the restaurant?
WITH temp AS (
  SELECT
    sales.customer_id,
    menu.price
  FROM dannys_diner.sales
  JOIN dannys_diner.menu ON (sales.product_id = menu.product_id)
)
SELECT
  customer_id,
  SUM(price) AS amount_spent
FROM temp
GROUP BY customer_id
ORDER BY customer_id;

 customer_id | amount_spent
-------------+--------------
 A           |           76
 B           |           74
 C           |           36


-- 2. How many days has each customer visited the restaurant?
SELECT
  customer_id,
  COUNT(distinct order_date) as visits
FROM dannys_diner.sales
GROUP BY customer_id;

 customer_id | visits
-------------+--------
 A           |      4
 B           |      6
 C           |      2
 

-- 3. What was the first item from the menu purchased by each customer?
WITH temp AS (
  SELECT
    sales.customer_id,
    menu.product_name,
    sales.order_date,
    ROW_NUMBER() OVER(PARTITION BY sales.customer_id ORDER BY sales.order_date ASC) AS order_number
  FROM dannys_diner.sales
  JOIN dannys_diner.menu ON (sales.product_id = menu.product_id)
)
SELECT
  customer_id,
  product_name
FROM temp
WHERE order_number = 1;

 customer_id | product_name
-------------+--------------
 A           | curry
 B           | curry
 C           | ramen


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT
  menu.product_name,
  COUNT(menu.product_id)
FROM dannys_diner.sales
JOIN dannys_diner.menu ON (sales.product_id = menu.product_id)
GROUP BY menu.product_name
ORDER BY count DESC;

 product_name | count
--------------+-------
 ramen        |     8
 curry        |     4
 sushi        |     3


-- 5. Which item was the most popular for each customer?
WITH temp AS (
  SELECT
    sales.customer_id,
    menu.product_name,
    COUNT(menu.product_name),
    RANK() OVER(PARTITION BY sales.customer_id ORDER BY COUNT(menu.product_name) DESC) AS order_rank
  FROM dannys_diner.sales
  JOIN dannys_diner.menu ON (sales.product_id = menu.product_id)
  GROUP BY sales.customer_id, menu.product_name
  ORDER BY sales.customer_id, order_rank ASC
)
SELECT
  customer_id,
  product_name AS most_popular
FROM temp
WHERE order_rank = 1;

 customer_id | most_popular
-------------+--------------
 A           | ramen
 B           | sushi
 B           | curry
 B           | ramen
 C           | ramen


-- 6. Which item was purchased first by the customer after they became a member?
WITH temp AS (
  SELECT
    sales.customer_id,
    sales.order_date,
    members.join_date,
    menu.product_name,
    RANK() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date ASC) AS order_rank
  FROM dannys_diner.sales
  JOIN dannys_diner.menu ON (sales.product_id = menu.product_id)
  JOIN dannys_diner.members ON (sales.customer_id = members.customer_id)
  WHERE sales.order_date >= members.join_date
  ORDER BY sales.customer_id, sales.order_date
)
SELECT
  customer_id,
  product_name
FROM temp
WHERE order_rank = 1;

 customer_id | product_name
-------------+--------------
 A           | curry
 B           | sushi


-- 7. Which item was purchased just before the customer became a member?
WITH temp AS (
  SELECT
    sales.customer_id,
    sales.order_date,
    members.join_date,
    menu.product_name,
    RANK() OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date DESC) AS order_rank
  FROM dannys_diner.sales
  JOIN dannys_diner.menu ON (sales.product_id = menu.product_id)
  JOIN dannys_diner.members ON (sales.customer_id = members.customer_id)
  WHERE sales.order_date < members.join_date
  ORDER BY sales.customer_id, sales.order_date
)
SELECT
  customer_id,
  product_name
FROM temp
WHERE order_rank = 1;

 customer_id | product_name
-------------+--------------
 A           | sushi
 A           | curry
 B           | sushi


-- 8. What is the total items and amount spent for each member before they became a member?
WITH temp AS (
  SELECT
    sales.customer_id,
    sales.order_date,
    members.join_date,
    menu.product_name,
    menu.price
  FROM dannys_diner.sales
  JOIN dannys_diner.menu ON (sales.product_id = menu.product_id)
  JOIN dannys_diner.members ON (sales.customer_id = members.customer_id)
  WHERE sales.order_date < members.join_date
  ORDER BY sales.customer_id
)
SELECT
  customer_id,
  COUNT(*) AS total_items,
  SUM(price) AS amount_spent
FROM temp
GROUP BY customer_id;

 customer_id | total_items | amount_spent
-------------+-------------+--------------
 A           |           2 |           25
 B           |           3 |           40


-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH temp AS (
  SELECT
    sales.customer_id,
    menu.product_name,
    menu.price
  FROM dannys_diner.sales
  JOIN dannys_diner.menu ON (sales.product_id = menu.product_id)
  ORDER BY customer_id
)
SELECT
  customer_id,
  SUM(
    CASE
      WHEN product_name = 'sushi' THEN 20 * price
      ELSE 10 * price
    END
  ) AS points
FROM temp
GROUP BY customer_id;

 customer_id | points
-------------+--------
 A           |    860
 B           |    940
 C           |    360


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not
--     just sushi - how many points do customer A and B have at the end of January?
WITH temp AS (
  SELECT
    sales.customer_id,
    sales.order_date,
    members.join_date,
    menu.product_name,
    menu.price
  FROM dannys_diner.sales
  JOIN dannys_diner.menu ON (sales.product_id = menu.product_id)
  JOIN dannys_diner.members ON (sales.customer_id = members.customer_id)
  WHERE order_date >= join_date
  ORDER BY sales.customer_id
)
SELECT
  customer_id,
  SUM(
    CASE WHEN product_name = 'sushi' OR order_date BETWEEN (join_date) AND (join_date + 7)
    THEN (price * 20)
    ELSE (price * 10)
    END
  ) AS total_points
FROM temp
GROUP BY customer_id;

 customer_id | total_points 
-------------+--------------
 A           |         1020 
 B           |          560 
