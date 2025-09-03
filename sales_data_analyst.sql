CREATE TABLE sales_analyst(
transaction_id VARCHAR(15),
customer_id VARCHAR(15),
customer_name VARCHAR(30),
customer_age INT,
gender VARCHAR(15),
product_id VARCHAR(15),
product_name VARCHAR(15),
product_category VARCHAR(15),
quantiy INT,
prce FLOAT,
payment_mode VARCHAR(15),
purchase_date DATE,
time_of_purchase TIME,
status VARCHAR(15)
);
SELECT * FROM sales_analyst
SET DATEFORMAT dmy
BULK INSERT  sales_analyst
FROM 'C:\Users\visha\Downloads\sales_store.csv'
   with(
      FIRSTROW=2,
      FIELDTERMINATOR=',',
      ROWTERMINATOR='\n'
   );
   --yyy--mm--date
   --data--cleaning
SELECT *FROM sales_analyst
SELECT * INTO sales_data FROM sales_analyst
SELECT *FROM sales_analyst
SELECT *FROM sales_data
--data cleaning
--step1: to check duplicate
SELECT transaction_id,count(*)
FROM sales
GROUP BY  transaction_id
HAVING COUNT(transaction_id)>1

with CTE AS(
SELECT *,
      ROW_NUMBER()OVER(PARTITION BY transaction_id ORDER BY transaction_id) AS ROW_NUM
FROM sales_data
)
--DELETE FROM CTE
--WHERE ROW_NUM=2
SELECT * FROM CTE
WHERE transaction_id IN('TXN240646','TXN342128','TXN855235','TXN981773')

--STEP:2 CORRECTION OF HEADERS
SELECT *FROM sales_data
EXEC  sp_rename'sales_data.quantiy','quantity','COLUMN'
EXEC  sp_rename'sales_data.prce','price','COLUMN'

--step3: to check daat type
SELECT COLUMN_NAME,DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='sales_data'

--step4: to check null values
--to check null count
DECLARE @SQL NVARCHAR(MAX)='';
SELECT @SQL = STRING_AGG(
     'SELECT ''' + COLUMN_NAME + ''' AS ColumnName,
     COUNT(*) AS NullCount
     FROM' + QUOTENAME(TABLE_SCHEMA) +'.sales_data
     WHERE' + QUOTENAME(COLUMN_NAME) +' IS NULL',
      ' UNION ALL'
)
WITHIN GROUP(ORDER BY COLUMN_NAME)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='sales_data';

--exceute the dynamic sql

EXEC sp_executesql @SQL;

--treating null values
SELECT *
FROM sales_data
WHERE transaction_id is null
or
customer_id is null
or
customer_name is null
or
customer_age is null
or
gender is null
or
payment_mode is null
or
purchase_date is null
or
status is null


DELETE  FROM sales
WHERE transaction_id is null

SELECT *FROM sales
where customer_name='Ehsaan Ram'

UPDATE sales
SET customer_id='CUST9494'
where transaction_id='TXN977900'


SELECT *FROM sales
where customer_name='Damini Raju'

UPDATE sales
SET customer_id='CUST1401'
where transaction_id='TXN985663'


SELECT *FROM sales
where customer_id='CUST1003'

UPDATE sales
SET customer_name='Mahika Saini',customer_age=35,gender='Male'
where transaction_id='TXN432798'

select * from sales

--step5: data clenaing
select distinct gender
from sales

update sales
set gender='M'
where gender='Male'

update sales
set gender='F'
where gender='Female'

select distinct payment_mode
from sales


update sales
set  payment_mode='Credit card'
where payment_mode='CC'

--data anlysis
--1. wht are top 5 selling producyts by quantity
 select * from sales
 select distinct status from sales


 select top 5 product_name,count(*)AS total_quantity_sold
 from sales
 where status='delivered'
 group by product_name
 order by  total_quantity_sold desc

 --2.which products mostly frequently cancelled
 
 select top 5 product_name,count(*)AS total_cancelled
 from sales
 where status='cancelled'
 group by product_name
 order by  total_cancelled desc

 --3.wht time of the day has the highest number of purchase
 select * from sales_data
        select
            CASE
                WHEN DATEPART(HOUR,time_of_purchase)BETWEEN 0 AND 5 THEN 'NIGHT'
                
                WHEN DATEPART(HOUR,time_of_purchase)BETWEEN 6 AND 11 THEN 'MORNING'
                WHEN DATEPART(HOUR,time_of_purchase)BETWEEN 12 AND 17 THEN 'AFTERNOON'
                WHEN DATEPART(HOUR,time_of_purchase)BETWEEN 18 AND 24 THEN 'EVENING'
            END AS time_of_day,
            COUNT(*) AS total_order
        FROM sales_data
        GROUP BY
            CASE
                WHEN DATEPART(HOUR,time_of_purchase)BETWEEN 0 AND 5 THEN 'NIGHT'
                
                WHEN DATEPART(HOUR,time_of_purchase)BETWEEN 6 AND 11 THEN 'MORNING'
                WHEN DATEPART(HOUR,time_of_purchase)BETWEEN 12 AND 17 THEN 'AFTERNOON'
                WHEN DATEPART(HOUR,time_of_purchase)BETWEEN 18 AND 24 THEN 'EVENING'
            END
ORDER BY total_order DESC



--4. WHO ARE TOP 5 HIGHEST SPENDING CUSTOMERS
SELECT *FROM sales_data
select customer_name,MAX(product_name) AS total_spend
FROM sales_data
GROUP BY customer_name 
ORDER BY total_spend DESC


--5. wht is the most prefreeed payment mode?


select * from sales_data

select payment_mode,count(payment_mode)AS total_count
FROM sales_data
GROUP BY payment_mode
ORDER BY total_count DESC


--6.are certain genders byuing more specific product categories
SELECt * from sales_data
SELECT gender,product_category,COUNT(product_category)AS total_purchase
FROM sales_data
GROUP BY gender,product_category
ORDER BY gender