/*
===============================================================================
Звіт про клієнтів
===============================================================================
Мета:
    - Цей звіт узагальнює ключові показники та особливості поведінки клієнтів.

Основні моменти:
    1. Збирає необхідні дані, такі як імена, вік і деталі транзакцій.
	2. Сегментує клієнтів за категоріями (VIP, Regular, New) and age groups.
    3. Агрегує показники на рівні клієнта:
	   - total orders             ( всього замовлень )
	   - total sales              ( всього продаж )
	   - total quantity purchased ( загальна придбана кількість )
	   - total products           ( всього продуктів )
	   - lifespan (in months)     ( тривалість життя )
    4. Розраховує цінні показники KPIs:
        - давність (кількість місяців з моменту останнього замовлення)
		- середня вартість замовлення
		- середні щомісячні витрати
===============================================================================
*/
WITH query_1 AS (
/*---------------------------------------------------------------------------
1) query_1: отримує основні стовпці з таблиць.
---------------------------------------------------------------------------*/
SELECT 
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
c.birthdate,
extract(YEAR FROM AGE(CURRENT_DATE, TO_DATE(c.birthdate, 'YYYY/MM/DD'))) AS age,
concat(c.first_name, ' ', c.last_name ) AS customer_name
FROM fact_sales f
LEFT JOIN dim_customers c
ON c.customer_key = f.customer_key 
WHERE order_date IS NOT NULL
),
customer_aggregation AS(
/*---------------------------------------------------------------------------
2) Customer Aggregations: Узагальнює ключові показники на рівні клієнта
---------------------------------------------------------------------------*/
SELECT 
   customer_key,
   customer_number,
   customer_name,
   birthdate,
   age,
   COUNT(DISTINCT order_number ) AS total_orders,
   SUM(sales_amount) AS total_sales,
   SUM(quantity ) AS total_quantity,
   COUNT(DISTINCT product_key) AS total_products,
   MAX(order_date) AS last_order_date,
   (extract(YEAR FROM age(max(order_date),MIN(order_date))) * 12 + extract(MONTH FROM age(max(order_date), MIN(order_date)))) AS lifespan
FROM query_1
GROUP BY customer_key,
         customer_number, 
         customer_name, 
         birthdate,
         age
 )
SELECT 
    customer_key,
    customer_number, 
    customer_name, 
    birthdate,
    age,
    CASE 
	   WHEN age < 20 THEN 'Under 20'
	   WHEN age between 20 and 29 THEN '20-29'
	   WHEN age between 30 and 39 THEN '30-39'
	   WHEN age between 40 and 49 THEN '40-49'
	   ELSE '50 and above'
END AS age_group,
    CASE 
       WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
       WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
       ELSE 'New'
END AS customer_segment,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    last_order_date,
    lifespan,
-- Compuate average order value (AVO)
    CASE WHEN total_sales = 0 THEN 0
	     ELSE total_sales / total_orders
END AS avg_order_value,
-- Compuate average monthly spend
    CASE WHEN lifespan = 0 THEN total_sales
         ELSE ROUND((total_sales / lifespan),2)
END AS avg_monthly_spend
FROM customer_aggregation

 
 
         











