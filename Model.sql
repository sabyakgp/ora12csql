with fact_table as (
SELECT  country_name country,country_subRegion region, prod_name product, calendar_year year, calendar_week_number week, 
SUM(amount_sold) sale, 
sum(amount_sold*
  ( case   
         when mod(rownum, 10)=0 then 1.4
         when mod(rownum, 5)=0 then 0.6
         
         when mod(rownum, 2)=0 then 0.9
         when mod(rownum,2)=1 then 1.2
         else 1
    end )) receipts
    
FROM sh.sales, sh.times, sh.customers, sh.countries, sh.products
WHERE sales.time_id = times.time_id AND
sales.prod_id = products.prod_id AND
sales.cust_id = customers.cust_id AND
customers.country_id = countries.country_id and
Prod_name = 'Xtend Memory' and Country_name ='Australia'
GROUP BY 
country_name,country_subRegion, prod_name, calendar_year, calendar_week_number
)
select product, country, year, week, inventory, sale, receipts
  from fact_table
  where country in ('Australia')
  model return updated rows
  partition by (product, country)
  dimension by (year, week)
  measures ( 0 inventory , sale, receipts)
  rules automatic order(
       inventory [year, week ] =
                                 nvl(inventory [cv(year), cv(week)-1 ] ,0)
                                  - sale[cv(year), cv(week) ] +
                                  + receipts [cv(year), cv(week) ]
   )
  order by product, country,year, week;
/
SELECT TO_CHAR(TO_DATE('01/01/2016','mm/dd/yyyy'),'J') FROM DUAL;
/
select to_date(2457389, 'J') from dual;
/
CREATE TABLE AGENT_FACT
AS
SELECT COCE_ID,
PAID_DATE,
CASE AGNT_TYPE
  WHEN 1 THEN 'SA'
  WHEN 2 THEN 'GA'
  ELSE 'MA'
END AS AGENT_TYPE,
AMOUNT
FROM (
select 
   ROUND(DBMS_RANDOM.VALUE(1999,2007)) as COCE_ID,
   TO_DATE(TRUNC(DBMS_RANDOM.VALUE(2457389,2457389+364)),'J') as PAID_DATE,
   ROUND(DBMS_RANDOM.VALUE(1,3)) AS AGNT_TYPE,
   TRUNC(DBMS_RANDOM.VALUE(10, 100),2) AS AMOUNT   
FROM
  (SELECT LEVEL FROM DUAL CONNECT BY LEVEL < 100)
)  
/
CREATE TABLE AGNT_PAID_SUMM
AS
SELECT 
 PAID_MM,
 SUM(NVL(GA_AMOUNT,0)) AS GA,
 SUM(NVL(SA_AMOUNT,0)) AS SA,
 SUM(NVL(MA_AMOUNT,0)) AS MA,
 (SUM(NVL(GA_AMOUNT,0)) + SUM(NVL(SA_AMOUNT,0)) + SUM(NVL(MA_AMOUNT,0))) AS TOTAL_AMOUNT,
 0 AS AMT_VAR
FROM ( 
SELECT
 COCE_ID,
 TO_CHAR(PAID_DATE,'MM') AS PAID_MM,
 GA_AMOUNT,
 SA_AMOUNT,
 MA_AMOUNT
FROM  
  (
SELECT * FROM AGENT_FACT
  ) PIVOT (SUM(AMOUNT) AS AMOUNT FOR (AGENT_TYPE) IN ('GA' AS GA, 'SA' AS SA, 'MA' AS MA))
)  
GROUP BY PAID_MM
--ORDER BY PAID_MM
/
SELECT * FROM AGNT_PAID_SUMM
/
SELECT 
  PAID_MM, 
  TOTAL_AMOUNT, 
  TRUNC(AMT_VAR*100, 2) AS VARIAN
FROM 
  AGNT_PAID_SUMM
MODEL RETURN UPDATED ROWS
DIMENSION BY (PAID_MM)
MEASURES (AMT_VAR, TOTAL_AMOUNT)
RULES 
(
AMT_VAR [PAID_MM] = ((TOTAL_AMOUNT[CV(PAID_MM)] - TOTAL_AMOUNT[to_char(CV(PAID_MM)-1,'FM00')])/TOTAL_AMOUNT[to_char(CV(PAID_MM)-1,'FM00')])
)
ORDER BY PAID_MM
/
select * from AGNT_PAID_SUMM
order by paid_mm
/
desc AGNT_PAID_SUMM