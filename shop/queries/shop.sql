/* 1. Для каждого населенного пункта рассчитать количество клиентов, зарегистрованных в
нем. Отсортируйте результат по убыванию количества клиентов. Укажите населенный
пункт, занимающий второе место по количеству клиентов;*/

SELECT city,
       COUNT(*) AS Количество
FROM clients
GROUP BY city
ORDER BY Количество DESC 
LIMIT 1, 1;


/* 2. Для каждого населенного пункта рассчитать процент клиентов, зарегистрованных в
нем. Для населенного пункта «клх Новочеркасск» укажите процент клиентов, зареги-
стрированных в нем;*/

SELECT city,
       ROUND(COUNT(id) * 100/cnt.cnt_clients, 2) AS '%'
FROM clients, (SELECT COUNT(*) AS cnt_clients
               FROM clients) AS cnt
GROUP BY city
HAVING city LIKE 'клх_Новочеркасск';

/* 3. Для каждой категории общее количество товаров, а также общую, минимальную, мак-
симальную и выборочную среднюю стоимость товаров. При необходимости результат
округлите до 2 знаков после запятой. Отсортируйте таблицу по выборочной средней
стоимости. Укажите группу, находящуюся на втором месте;*/

SELECT category,
       COUNT(id) AS cnt_name,
       ROUND(SUM(cost),2) AS sum_cost,
       ROUND(MIN(cost),2) AS min_cost,
       ROUND(MAX(cost),2) AS max_cost,
       ROUND(AVG(cost),2) AS avg_cost
FROM products 
GROUP BY category 
ORDER BY avg_cost
LIMIT 1, 1;

--4. Укажите количество заказов, совершенных с "2022-01-01" по "2022-06-01" включительно

SELECT COUNT(DISTINCT id) as cnt_orders
FROM orders 
WHERE date BETWEEN '2022-01-01' AND '2022-06-01';

--5. Укажите максимальную стоимость заказа с учетом скидки;

WITH sum_orgers
AS (SELECT positions.order_id,
           SUM(positions.number * (products.cost - (products.cost/100 * positions.sale))) as sum_orger
    FROM positions 
    INNER JOIN products  
    ON positions.product_id = products.id 
    GROUP BY positions.order_id)
SELECT MAX(sum_orger)
FROM sum_orgers;

--6. Укажите наиболее продаваемый товар по количеству штук;

SELECT products.name,
       SUM(positions.number)
FROM positions 
INNER JOIN products  
ON positions.product_id = products.id 
GROUP BY products.name 
ORDER BY SUM(positions.number) DESC ;


