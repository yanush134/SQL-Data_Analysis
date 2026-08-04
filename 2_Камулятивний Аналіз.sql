/*
===============================================================================
Кумулятивний аналіз
===============================================================================
Мета:
    - Для розрахунку наростаючих підсумків або ковзних середніх для ключових показників.
    - Відстежувати ефективність із плином часу в накопичувальному порядку.
    - Корисно для аналізу зростання або виявлення довгострокових тенденцій.

SQL Що викристовувались:
    - Window Functions: SUM() OVER(), AVG() OVER()
===============================================================================
*/

-- Розрахунок загального обсягу продажів за місяць.
-- та наростаючий підсумок продажів із плином часу
select 
    order_date,
    total_sales,
    SUM(total_sales) over(partition by order_date order by order_date) as running_total,
    AVG(avg_price) over(order by order_date )
from 
(
   select 
       to_char(order_date,'yyyy') as order_date,
       SUM(sales_amount) as total_sales,
       ROUND(AVG(price),0) as avg_price
from fact_sales 
where to_char(order_date,'yyyy-MM') is not null
group by to_char(order_date,'yyyy')
order by to_char(order_date,'yyyy')
) t












