/*
===============================================================================
Аналіз ефективності (Year-over-Year, Month-over-Month)
===============================================================================
Мета:
    - Вимірування ефективності продуктів, клієнтів або регіонів з плином часу.
    - Для бенчмаркінгу та визначення високопродуктивних об'єктів.
    - Для відстеження річних тенденцій та зростання

SQL Функції що були використані:
    - LAG() OVER() Отримує доступ до даних із попередніх рядків.
    - AVG() OVER() Обчислює середні значення в межах розділів.
    - CASE: Визначає умовну логіку для аналізу тенденцій.
===============================================================================
*/

/* Проаналізуйте річні показники ефективності продуктів, 
   порівнявши обсяги їхніх продажів як із середнім показником продажів продукту, 
   так і з показниками попереднього року.*/

with yearly_product_sales as (
  select
      to_char(f.order_date, 'yyyy') as order_year,
      p.product_name,
      SUM(f.sales_amount) as current_sales
  from fact_sales f    
  left join dim_products p 
       on p.product_key = f.product_key
  where f.order_date is not null 
  group by  to_char(f.order_date, 'yyyy'), p.product_name
)
select 
   order_year,
   product_name,
   current_sales,
   AVG(current_sales) OVER(partition by product_name  ) as avg_sales,
   current_sales - AVG(current_sales) OVER(partition by product_name )as diff_avg,
   case when current_sales - AVG(current_sales) OVER(partition by product_name )> 0 then 'Above avg'
        when current_sales - AVG(current_sales) OVER(partition by product_name )< 0 then 'Below avg'
        else 'Avg'
        end avg_change,
   LAG(current_sales)  OVER(partition by product_name order by order_year) as py_sales ,
   current_sales - LAG(current_sales)  OVER(partition by product_name order by order_year) as diff_py,
   case when current_sales - LAG(current_sales)  OVER(partition by product_name order by order_year) > 0 then 'Increase'
        when current_sales - LAG(current_sales)  OVER(partition by product_name order by order_year) < 0 then 'Decrease'
        else 'No Change'
   end py_change     
from yearly_product_sales  
order by product_name, order_year




