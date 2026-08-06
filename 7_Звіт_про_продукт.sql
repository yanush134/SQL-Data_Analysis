 /*
===============================================================================
Звіт про продукт
===============================================================================
Мета:
    - Цей звіт узагальнює ключові показники продукту та особливості поведінки.

Основні моменти:
    1. Збирає ключові дані, такі як назва товару, категорія, підкатегорія та собівартість.
    2. Сегментує товари за показником доходу для виділення груп із високою, середньою та низькою ефективністю.
    3. Агрегує показники на рівні товарів:
       - загальна кількість замовлень
       - загальний обсяг продажів
       - загальна кількість проданих одиниць
       - загальна кількість клієнтів (унікальних)
       - тривалість співпраці (у місяцях)
    4. Розраховує цінні показники KPIs:
       - давність (кількість місяців з моменту останнього продажу)
       - середній дохід від замовлення (AOR)
       - середній щомісячний дохід.
===============================================================================
*/
 WITH query_1 AS(
 /*---------------------------------------------------------------------------
1) Базовий запит: отримує основні стовпці з fact_sales та dim_products
---------------------------------------------------------------------------*/
 SELECT
	    f.order_number,
        f.order_date,
		f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM fact_sales f
    LEFT JOIN dim_products p
        ON f.product_key = p.product_key
    WHERE order_date IS NOT NULL  -- враховувати лише дійсні дати продажу
    )
    ,product_aggregations AS(
    /*---------------------------------------------------------------------------
2) Агрегація даних за продуктами: узагальнення ключових показників на рівні продукту.
---------------------------------------------------------------------------*/
    SELECT 
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(quantity ) AS total_quantity,
        SUM(cost) AS total_sales,
        MAX(order_date) AS last_order,
        ROUND(AVG(sales_amount/quantity),1) AS avg_selling_price,
        (extract(YEAR FROM age(max(order_date),MIN(order_date))) * 12 + extract(MONTH FROM age(max(order_date), MIN(order_date)))) AS lifespan
    FROM query_1
    GROUP BY 
        product_key,
        product_name,
        category,
        subcategory,
        cost
 )
/*---------------------------------------------------------------------------
  3) Кінцевий запит: об’єднує всі результати щодо продуктів в один вивід.
---------------------------------------------------------------------------*/
SELECT 
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_order,
	lifespan,
	CASE
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment,
	lifespan,
	total_orders,
	total_sales,
	total_quantity,
	total_customers,
	avg_selling_price,
	-- Середній дохід від замовлення (AOR)
	CASE 
		WHEN total_orders = 0 THEN 0
		ELSE total_sales / total_orders
	END AS avg_order_revenue,
	-- Середній щомісячний дохід
	CASE
		WHEN lifespan = 0 THEN total_sales
		ELSE ROUND(total_sales / lifespan,0)
	END AS avg_monthly_revenue
FROM product_aggregations 




