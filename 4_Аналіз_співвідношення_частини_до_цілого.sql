/*
===============================================================================
Аналіз співвідношення частини й цілого
===============================================================================
Мета:
    - Для порівняння показників або метрик за різними вимірами чи періодами часу.
    - Щоб оцінити відмінності між категоріями.
    - Корисно для A/B-тестування або регіональних порівнянь.
SQL Функції що були використані:
    - SUM(), AVG(): Агрегує значення для порівняння.
    - Window Functions: SUM() OVER() для загального розрахунку.
===============================================================================
*/
--Які категорії роблять найбільший внесок у загальний обсяг продажів?
with category_sales as (
    select 
          p.category,
          SUM(f.sales_amount) as total_sales
    from fact_sales f
    left join dim_products p
       on p.product_key = f.product_key 
    group by category  
)
select 
      category,
      total_sales,
      SUM(total_sales) OVER(),
      ROUND((total_sales/SUM(total_sales) OVER() ) * 100, 2) as percentage_of_total
from category_sales
order by total_sales desc;
    



