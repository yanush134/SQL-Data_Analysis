/*
===============================================================================
Аналіз змін за весь час
===============================================================================
Мета:
    - Для відстеження тенденцій, зростання та змін ключових показників із плином часу.
    - Для аналізу часових рядів і виявлення сезонності.
    - Для вимірювання зростання або спаду протягом певних періодів.

SQL Функції що використовував:
    - Date Functions: EXTRACT(), DATE_TRUNC(), TO_CHAR()
    - Aggregate Functions: SUM(), COUNT()
===============================================================================
*/

-- Проаналізуйте динаміку показників продажів.
-- Функції швидкої роботи з датами
-- EXTRACT
select 
    EXTRACT(year from order_date) as order_year ,
    EXTRACT(month from order_date) as order_month,
    SUM(sales_amount ) as total_Sales,
    COUNT(distinct customer_key) as total_customer,
    SUM(quantity) as total_quantity
from fact_sales 
where order_date is not null 
group by EXTRACT(year from order_date),EXTRACT(month from order_date)
order by EXTRACT(year from order_date),EXTRACT(month from order_date)

-- DATE TRUNC
select 
    DATE_TRUNC('month',order_date ) as order_year ,
    SUM(sales_amount ) as total_Sales,
    COUNT(distinct customer_key) as total_customer,
    SUM(quantity) as total_quantity
from fact_sales 
where order_date is not null 
group by DATE_TRUNC('month',order_date )
order by DATE_TRUNC('month',order_date )

-- TO_CHAR
select 
to_char(order_date, 'yyyy-MM' ) as order_year ,
SUM(sales_amount ) as total_Sales,
COUNT(distinct customer_key) as total_customer,
SUM(quantity) as total_quantity
from fact_sales 
where order_date is not null 
group by to_char(order_date, 'yyyy-MM' )
order by to_char(order_date, 'yyyy-MM' )








