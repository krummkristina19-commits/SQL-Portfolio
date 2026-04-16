-- Знакомство с данными

--- Просмотр фрагмента данных

SELECT * 
FROM costs 
LIMIT 10;

--- Размерность

SELECT COUNT(*) 
FROM costs;

--- Просмотр уникальных значений
SELECT DISTINCT source_id 
FROM costs ;

---Описательные статистики по количественным признакам

SELECT MIN(costs),
       MAX(costs),
       AVG(costs)
FROM costs ;


--Решение задач:

--1. Изучить распределение затрат на рекламные источники;

SELECT source_id,
       SUM(costs) 
FROM costs 
GROUP BY source_id
ORDER BY SUM(costs) DESC ;

-- вариант 2



SELECT source_id,
       STRFTIME('%Y', dt) as year_costs,
       SUM(costs)
FROM costs 
GROUP BY  source_id,year_costs
ORDER BY SUM(costs) DESC ;

--2. Определите, сколько раз за день пользователи в среднем заходят на сайт.

WITH clients_count
As (SELECT strftime('%Y-%m-%d', start_ts) day_costs,
           count(uid) count_users
    from visits
    GROUP by strftime('%Y-%m-%d', start_ts)),
    d_clients_count
As (SELECT strftime('%Y-%m-%d', start_ts) day_costs,
           count(DISTINCT uid) unique_users
    from visits
    GROUP by strftime('%Y-%m-%d', start_ts))
SELECT clients_count.day_costs,
       clients_count.count_users,
       d_clients_count.unique_users,
       round(clients_count.count_users*1.0 / d_clients_count.unique_users, 2) avg_users_day
from clients_count
INNER join d_clients_count
on clients_count.day_costs = d_clients_count.day_costs
limit 10;

-- или

SELECT strftime('%Y-%m-%d', start_ts) day_costs,
       count(uid) count_visits,
       count(DISTINCT uid) count_unique_clients,
       round(count(uid)*1.0 / count(DISTINCT uid), 2) avg_visits_day
from visits
GROUP by strftime('%Y-%m-%d', start_ts);

-- 3. Исследуйте, сколько времени пользователи проводят на сайте. 
-- Узнайте продолжительность типичной пользовательской сессии за весь период.

WITH t_temp
AS (SELECT v.uid,
           v.start_ts,
           v.end_ts,
           (STRFTIME('%s', v.end_ts) - STRFTIME('%s', v.start_ts))/60 as session_duration_minute
    FROM visits v)
SELECT AVG(session_duration_minute)
FROM t_temp ;

--или

SELECT AVG((STRFTIME('%s', v.end_ts) - STRFTIME('%s', v.start_ts))/60)
FROM visits v;

--4. Исследуйте, сколько времени в среднем проходит с момента первого посещения сайта до совершения покупки.

WITH tabl_visit_min
AS (SELECT uid,
           min(start_ts) as time_first_vizit
    FROM visits
    GROUP BY uid),
     tabl_orders_min
AS (SELECT uid,
           min(buy_ts) as time_first_order
    FROM orders
    GROUP BY uid)
SELECT AVG((STRFTIME('%s', t1.time_first_order) - STRFTIME('%s', t2.time_first_vizit))/60.0) as avg
FROM tabl_orders_min t1
LEFT JOIN tabl_visit_min t2
ON t1.uid = t2.uid; 


--5. Рассчитайте средний чек.

SELECT SUM(revenue)/COUNT(*)
FROM orders;

--6. Рассчитайте DAU, WAU и MAU. Вычислите средние значения этих метрик за весь период.
--DAU

WITH DAU
AS (SELECT STRFTIME('%Y-%m-%d', start_ts) day,
           COUNT(DISTINCT uid) cnt_unicue_users
    FROM visits 
    GROUP BY STRFTIME('%Y-%m-%d', start_ts))
SELECT AVG(cnt_unicue_users ) as DAU
FROM DAU

--WAU

WITH WAU
AS (SELECT STRFTIME('%Y', start_ts) year_,
           STRFTIME('%W', start_ts) week,
           COUNT(DISTINCT uid) cnt_unicue_users
    FROM visits 
    GROUP BY STRFTIME('%Y', start_ts), STRFTIME('%W', start_ts))
SELECT AVG(cnt_unicue_users ) as WAU
FROM WAU;

--MAU


WITH MAU
AS (SELECT STRFTIME('%Y', start_ts) year_,
           STRFTIME('%m', start_ts) month,
           COUNT(DISTINCT uid) cnt_unicue_users
    FROM visits 
    GROUP BY STRFTIME('%Y', start_ts), STRFTIME('%m', start_ts))
SELECT AVG(cnt_unicue_users ) as MAU
FROM MAU;



