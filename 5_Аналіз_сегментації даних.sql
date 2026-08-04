/*
===============================================================================
Аналіз сегментації даних
===============================================================================
Мета:
    - Групування даних за змістовними категоріями для отримання цілеспрямованих висновків.
    - Для сегментації клієнтів, категоризації продуктів або регіонального аналізу.

SQL Функції що були використані:
    - CASE: Визначає власну логіку сегментації.
    - GROUP BY: групує дані по сегментам.
===============================================================================
*/

/*Розподіліть товари за ціновими діапазонами та 
підрахуйте кількість товарів у кожному сегменті.*/
with product_segment as(
   select 
      product_key,
      product_name,
      cost,
      case
    	  when cost < 100 then 'Below 100'
    	  when cost between 100 and 500 then '100-500'
    	  when cost between 500 and 1000 then '500-1000'
    	  else 'Above 1000'
     end products_group   
     from dim_products
)
select 
    products_group,
    COUNT(product_key) as total_products
from product_segment
group by products_group 
order by total_products desc

/*Розподіліть клієнтів на три сегменти на основі їхніх витрат:
	- VIP: клієнти з історією співпраці щонайменше 12 місяців і витратами понад 5 000 євро.
	- Постійні: клієнти з історією співпраці щонайменше 12 місяців, але з витратами 5 000 євро або менше.
	- Нові: клієнти з періодом співпраці менше 12 місяців.
Також визначте загальну кількість клієнтів у кожній групі.
*/
with customer_spending as (
    select  
         dc.customer_key,
         SUM(t.sales_amount ) as total_spending,
         MIN(order_date) as first_order,
         MAX(order_date) as last_order,
         (MAX(order_date) - MIN(order_date))/30  AS lifespan     
    from fact_sales t
    left join dim_customers dc 
        on dc.customer_key = t.customer_key  
    group by  dc.customer_key    
)

select customer_segment,
       COUNT(customer_key) as total_customers
from ( 
      select customer_key,
             CASE 
             WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
             WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
             ELSE 'New'
        END AS customer_segment
     FROM customer_spending
) AS segmented_customers
GROUP BY customer_segment
ORDER BY total_customers DESC;







