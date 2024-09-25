create database  Practice 

use Practice

create table sales(sales_id varchar(max),dates varchar(max),store_id varchar(max),product_id varchar(max),units varchar(max))

select * from sales

create table store(store_id varchar(max),store_name varchar(max),store_city varchar(max),store_location  varchar(max),store_open_date varchar(max))

select * from store

create table product(product_id varchar(max),product_name varchar(max),product_category varchar(max),product_cost varchar(max),product_price varchar(max))

select * from product

create table inventory(store_id varchar(max),product_id varchar(max),stock_on_hand varchar(max))
select * from inventory

bulk insert sales
from 'C:\Users\Admin\Favorites\Downloads\sales.csv'
with(fieldterminator=',',rowterminator='\n',firstrow=2,maxerrors=40)

bulk insert store
from 'C:\Users\Admin\Favorites\Downloads\stores.csv'
with(fieldterminator=',',rowterminator='\n',firstrow=2,maxerrors=40)

bulk insert product
from 'C:\Users\Admin\Favorites\Downloads\products.csv'
with(fieldterminator=',',rowterminator='\n',firstrow=2,maxerrors=40)

bulk insert inventory
from 'C:\Users\Admin\Favorites\Downloads\inventory.csv'
with(fieldterminator=',',rowterminator='\n',firstrow=2,maxerrors=40)

---------    DATA CLEANING AND PREPROCESSING    ------------------------

select column_name,data_type
from information_schema.COLUMNS
where TABLE_NAME='sales'

select * from sales
where ISNUMERIC(sales_id)=0

select * from sales
where ISDATE(dates)=0

select * from sales
--where ISNUMERIC(store_id)=0
--where ISNUMERIC(product_id)=0
where ISNUMERIC(units)=0

---anomalies in two columns

update sales set sales_id=
--select
case when sales_id like '%[^0-9]%' then REPLACE(sales_id,SUBSTRING(sales_id,PATINDEX('%[^0-9]%',sales_id),1),'') else sales_id end
from sales
where sales_id like '%[^0-9]%'

alter table sales
alter column sales_id int 
  
alter table sales
alter column dates date --issue

alter table sales
alter column store_id int

alter table sales
alter column product_id int 


update sales set units= case when units like '%[^0-9]%' then REPLACE(units,SUBSTRING(units,Patindex('%[^0-9]%',units),1),'') else units end 
where units like '%[^0-9]%'

alter table sales
alter column units int

select dates from sales
where dates like '%/2022/%'


update sales set dates= stuff(replace(Dates,'2022','4'),1,1,'2022') 
from sales
where Dates like '__/2022/%' or Dates like '_/2022/%' or Dates like '_/2023/%' or Dates like '__/2022/%'

select * from sales

alter table sales
alter column dates date 

select dates from sales
where dates like '%__-__-2022%' or dates like '%_-_-2022%'

select COLUMN_NAME,DATA_TYPE
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='sales'

alter table sales
alter column sales_id int

-------Products
select column_name,data_type
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='product'

select* from product

alter table product
alter column product_id int

update product set product_cost=REPLACE(product_cost,'$','')
from product

alter table product
alter column product_cost decimal(7,2)

update product set product_price=REPLACE(product_price,'$','')
from product

alter table product
alter column product_price decimal(7,2)

-----Store
select * from store

select column_name,data_type
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='store'

select * from store

alter table store
alter column store_id int

alter table store
alter column store_open_date date

update store set store_open_date=TRY_CONVERT(date,store_open_date,103)

-----inventory
select * from inventory

select column_name,data_type
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='inventory'

alter table inventory
alter column store_id int

alter table inventory
alter column product_id int

alter table inventory
alter column stock_on_hand int

----check duplicate
select * from sales
select * from product
select * from store
select * from inventory

select distinct(sales_id) from sales
select distinct(product_id) from product

with dupli as (select * ,ROW_NUMBER() over (partition by product_id,product_name,product_category,product_cost,product_price order by(product_id)) as rownumber
from product)
select
--delete 
*from dupli
where rownumber>1

-------- EXPLORATORY DATA ANALYSIS -----------------

---SALES PERFORMANCE EVALUATION

select MIN(dates),MAX(dates) from sales ---SALES PERIOD

select year(dates),sum(units)
from sales
group by year(dates) ----in the year 2022 we sold many number of products

select DATENAME(month,dates) as months , SUM(units) as noofsales
from sales
group by DATENAME(month,dates)
order by SUM(units) desc

select DATENAME(month,dates) as months , SUM(units) as noofsales ,p.product_category
from sales , product as p
where FORMAT(dates,'yyyy') = 2022
group by DATENAME(month,dates),p.product_category
order by SUM(units) desc ----- trends near to yearend

select DATENAME(month,dates) as months , SUM(units) as noofsales ,p.product_category
from sales , product as p
where FORMAT(dates,'yyyy') = 2023
group by DATENAME(month,dates),p.product_category
order by SUM(units) desc     -----------  peak at march 
---------NO SEASONALITY

select   DATENAME(WEEKDAY,dates) as months,DATENAME(YEAR,dates) as years, SUM(units) as noofsales
from sales
where FORMAT(dates,'yyyy') = 2022
group by DATENAME(WEEKDAY,dates),DATENAME(YEAR,dates)
order by SUM(units) desc

select   DATENAME(WEEKDAY,dates) as months,DATENAME(YEAR,dates) as years, SUM(units) as noofsales
from sales
where FORMAT(dates,'yyyy') = 2023
group by DATENAME(WEEKDAY,dates),DATENAME(YEAR,dates)
order by SUM(units) desc
---------  SEASONALITY based on weekday (FRIDAY SATURDAY we have highest sales)

---COMPARISION  SALES PERFORMANCE OVER THE TIME
With sale As (select datename(month,dates) as 'months', sum(case when year(dates)='2022' then units else 0 end ) as 'salesof2022' ,
           sum(case when year(dates)='2023' then units else 0 end) as 'salesof2023',
           (sum(case when year(dates)='2023' then units else 0 end))-(sum(case when year(dates)='2022' then units else 0 end)) as 'diffofsales'
           from sales
group by datename(MONTH,dates))
select *,round(cast((100*diffofsales/salesof2022)as float),2) as percentagediffage,
case when diffofsales<0 then 'DICLINE'
     when diffofsales>0 
	 then 'incline'
	 else ''
	 end as 'statusofdiff'
from sale
--------SALES INCREASES OVER THE year 

------ STORE PERFORMANCE --------------------

select  top 5 st.store_city , sum(s.units)
from sales s
join 
store st on st.store_id=s.store_id
group by st.store_city
order by SUM(s.units) desc 

select st.store_location,sum(s.units) as 'totalsales' from 
sales s
join 
store st on s.store_id=st.store_id
group by st.store_location
order by SUM(s.units) desc ---highest at downtown 

select   st.store_location, count(st.store_id) as 'no_of_stores'
from
store st 
group by st.store_location
order by COUNT(st.store_id) desc
-------------  more no of STORES more SALES

select   st.store_city , sum(s.units) as 'noofsales'
from sales s
join 
store st on st.store_id=s.store_id
where st.store_location='Airport'
group by st.store_city
order by SUM(s.units) desc

--- analysis of store base on inventory
select * from store
select * from inventory

select Top 10 s.store_id ,s.store_name,SUM(i.stock_on_hand)
from store s
right join
inventory i on s.store_id=i.store_id
group by s.store_id,s.store_name
order by SUM(i.stock_on_hand) desc


--------- PRODUCT PERFORMANCE -----------------

select  product_category,product_name,sum(product_price) as 'price' ,sum(product_cost) as 'cost'
from product
group by product_category,product_name
order by SUM(product_price) desc



select* from sales
select * from product 

---- TOP PERFORMING PRODUCTS
With Product_perf as (select p.product_category,p.product_name ,sum(s.units) as 'totalunits',ROW_NUMBER() over(partition by p.product_category order by (sum(units)) desc) as rownum
from product p 
join sales s on s.product_id=p.product_id
group by p.product_category,p.product_name
)

select * from Product_perf
where rownum=1  ---------------PlayDoh Can,Colorbuds,Deck Of Cards,Dart Gun,Dino Egg

-----LEAST PERFORMING PRODUCTS
With Product_perf as (select p.product_category,p.product_name ,sum(s.units) as 'totalunits',ROW_NUMBER() over(partition by p.product_category order by (sum(units)) desc) as rownum
from product p 
join sales s on s.product_id=p.product_id
group by p.product_category,p.product_name
),
MaxRowNum AS (SELECT product_category, MAX(rownum) AS max_rownum FROM Product_perf
    GROUP BY product_category
)

SELECT pp.product_category, pp.product_name, pp.totalunits
FROM  Product_perf pp
JOIN MaxRowNum mrn ON pp.product_category = mrn.product_category AND pp.rownum = mrn.max_rownum
ORDER BY pp.product_category
----Playfoam,Toy Robot,Uno Card Game,Mini Basketball Hoop,Plush Pony

---- REVENUE MARGIN
select p.product_category,sum(s.units * p.product_price) as 'revenue'  from sales s 
join product p on s.product_id=p.product_id
group by p.product_category
order by sum(s.units * p.product_price) desc

select s.store_location ,sum(sl.units * p.product_price) as 'revenue' from store s
join sales sl on s.store_id=sl.store_id
join product p on sl.product_id=p.product_id
group by s.store_location
order by sum(sl.units * p.product_price) desc


With revenue as (select s.store_location ,sum(sl.units * p.product_price) as 'revenues' from store s
join sales sl on s.store_id=sl.store_id
join product p on sl.product_id=p.product_id
group by s.store_location)
--order by sum(sl.units * p.product_price) desc

select *,(revenues*100)/14444572.35 as '%revenue' from revenue
order by revenues desc

------ PROFIT MARGIN
with l as (select p.product_id, p.product_name,p.product_price,p.product_cost ,p.product_category,sum(s.units) as 'totalsale',
sum(s.units * p.product_price) as 'revenue',sum(s.units * (p.product_price-p.product_cost)) as 'profit'
from product p
join sales s on s.product_id=p.product_id
group by p.product_id,p.product_name,p.product_price,p.product_cost,p.product_category
--order by profit desc
)

select * from l
where profit<0
order by profit desc  -------------21 products are under loss out of 35 almost 60% of product are at loss because of cost is higher then price
----This is the resaon we have financial issue and lossing market position

/*
Cost Reduction Strategies
Supply Chain Optimization: Review suppliers and procurement strategies to find more cost-effective solutions for producing or sourcing products.
Lean Practices: Implement lean manufacturing principles to reduce waste and lower costs in production.
*/

select * from product 
with loc as (select s.store_location,s.store_city, sum(p.product_price * sl.units )  as 'revenue' , SUM(sl.units *(p.product_price-p.product_cost)) as 'Profit',
ROW_NUMBER()over(partition by(s.store_location) order by(SUM(sl.units *(p.product_price-p.product_cost)))desc ) as 'row_no'
from store s
join sales sl  on sl.store_id =s.store_id
join product p on sl.product_id=p.product_id
group by s.store_location,s.store_city)
--order by  SUM(sl.units *(p.product_price-p.product_cost)) desc

select  *,round(cast(((100*profit)/4014029.00)as float) ,2) as '%profit'from loc
where row_no =1
order by profit desc

/*here we can found in airport region items are high at cost because of 
      Many airport vendors offer promotions or discounts to entice travelers who may be in a hurry or making impulse purchases.
	  Airports often have numerous retailers, restaurants, and service providers competing for travelers, leading to competitive pricing to attract customers.

Recommendation:
Introduce exclusive products or services that cannot be found elsewhere. This can justify higher prices and attract customers looking for something special.
Implement loyalty programs that reward frequent travelers, encouraging repeat business and fostering customer loyalty.
*/

with prod as (select p.product_category,p.product_name, sum(p.product_price * s.units )  as 'revenue' , SUM(s.units *(p.product_price-p.product_cost)) as 'Profit',
ROW_NUMBER()over(partition by(p.product_category) order by(SUM(s.units *(p.product_price-p.product_cost)))desc ) as 'row_no'
from sales s
join product p on s.product_id=p.product_id
group by p.product_category,p.product_name)
--order by  SUM(sl.units *(p.product_price-p.product_cost)) desc

select  *,round(cast(((100*profit)/4014029.00)as float) ,2) as '%profit'from prod
where row_no =1
order by profit desc
/*  we have lowest profit when it comes to Art&craft and games section so 
       we can Conduct a cost analysis to identify opportunities for price adjustments without significantly affecting demand.
*/

select dateadd(month,-6,max(dates))from sales ---2023-03-30
select MAX(dates) from sales --2023-09-30



---LAST 6 MONTHS ANALYSIS


-----------------------REPORT-------------------

with report as (
select s.dates,st.store_location,st.store_city,p.product_category,p.product_name,
SUM(s.units) as 'Total_units',SUM(p.product_price*s.units) 'Total_Sales',SUM((p.product_price-p.product_cost)*s.units) 'Profit'
from store st join sales s  on st.store_id=s.store_id join product p on p.product_id=s.product_id
group by s.sales_id,s.dates,st.store_location,st.store_city,p.product_category,p.product_name
),

last6mon as (select dates,store_location,Total_units,Total_Sales,Profit 
from report
where dates between DATEADD(MONTH,-6, (select max(dates) from sales )) and (select MAX(dates) from sales)
),

Previous6mon as (select dates,store_location,Total_units,Total_Sales,Profit
from report
where dates between DATEADD(MONTH,-6, '2022-12-31') and '2022-12-31'
)

--select((sum(Profit))*100)/4014029.00 as '2023SIXmonprofit%'  from last6mon 
select((sum(Profit))*100)/4014029.00 as '2022SIXmonprofit%'  from Previous6mon 


--- COMPLETE SALES MONTH WISE REPORTING --------
with compsales as(select month(s.dates) as months,year(s.dates) as 'years',SUM(s.units) as 'Total_units',SUM(p.product_price*s.units) 'Total_Sales',
SUM((p.product_price-p.product_cost)*s.units) 'Profit'
from store st join sales s  on st.store_id=s.store_id join product p on p.product_id=s.product_id
group by MONTH(s.dates),YEAR(s.dates)),

privyear as (select months,years ,Total_units,Total_sales,Profit,((Profit)*100)/4014029.00  'percprofit' from compsales
where years='2022'),

recentyear as (select  months,years ,Total_units,Total_sales,Profit,((Profit)*100)/4014029.00  'percprofit' from compsales
where years='2023')

select p.months,p.years,p.total_units,p.total_sales,p.profit,p.percprofit,r.years,r.total_units,r.total_sales,r.profit,r.percprofit
from privyear p left join recentyear  r on r.months=p.months

--- QUARTILE WISE SALES REPORT ----------------------
With Comp_sales as( select p.Product_category ,YEAR(s.dates) as 'year/s', DATEPART(quarter,s.dates) as 'quarterlys' , SUM(s.units) as 'total_no_sold'
from sales s
join product p on s.Product_ID=p.Product_ID
group by p.Product_category,DATEPART(quarter,s.dates),YEAR(s.dates)),
--select * from Comp_sales
/* Previous year sales*/
Prev_sales  as (select Product_category,quarterlys ,total_no_sold as 'Prev_yr_unitsold' 
from Comp_sales 
where [year/s]=2022),

/*current year sales-2023*/
Current_sales  as (select Product_category,quarterlys ,total_no_sold as 'crnt_yr_unitsold'
from Comp_sales 
where [year/s]=2023)

select c.Product_category,c.quarterlys,p.prev_yr_unitsold,c.crnt_yr_unitsold,(c.crnt_yr_unitsold - p.Prev_yr_unitsold) as 'Diff'
from Current_sales c
join Prev_sales p
on c.Product_category = p.Product_category
and c.quarterlys=p.quarterlys
----------- TOYS and Art&Craft are in profit 

--Inventory turnover ratio between 2022 and 2023(leaf1,4 method in finance)

  --sales by category
  select * from Inventory

With sales_category as(
  select p.Product_Name , 
  SUM(case when year(s.Dates)=2022 then s.Units*p.Product_Cost else 0 end ) as cogs_2022,
  sum(case when year (s.Dates)=2023 then s.Units*p.Product_Cost else 0  end ) as cogs_2023
  from sales s
  join product p on s.Product_ID=p.Product_ID
  group by p.Product_Name)

  /* average inventory */
  ,avg_inventory as (select p.Product_Name, AVG(case when year(s.dates)=2022 then i.stock_on_hand else 0 end) as Avg_inventory_2022,
  Avg(case when year(s.Dates)=2023 then i.Stock_on_hand else 0 end) as Avg_inventory_2023  
  from inventory i 
  join product p on i.Product_ID=p.Product_ID
  join sales s on i.Product_ID=s.Product_ID
  group by p.Product_Name)

  select sc.Product_Name,sc.cogs_2022,ai.Avg_inventory_2022,case when ai.Avg_inventory_2022=0 then null
  else (sc.cogs_2022/ai.avg_inventory_2022) end as Inv_turn_ratio_2022, sc.cogs_2022,ai.Avg_inventory_2023,
  case when ai.Avg_inventory_2023=0 then null
  else (sc.cogs_2023/ai.avg_inventory_2023) end  as Inv_turn_ratio_2023
  from sales_category sc
  join avg_inventory ai
  on sc.Product_Name =ai.Product_Name

  ---top over stock items are uno Card game from though out the year trhis can be avoid by doing Demand forecasting
 --Inventory turnover ratio cogs/avg_inv 

 -------stockout analysis

select * from sales
select * from product
select * from store
select * from inventory

select p.product_id, p.product_name,s.store_name,i.stock_on_hand from product p
join inventory i on p.product_id = i.product_id
join store s  on  s.store_id=i.store_id
where i.stock_on_hand = 0
order by product_id

with t as (select  distinct p.product_id, p.product_name from product p
join inventory i on p.product_id = i.product_id
join store s  on  s.store_id=i.store_id
where i.stock_on_hand = 0)


 select (cast((select COUNT(distinct(product_name)) from t)as float) /cast((select COUNT(distinct(product_name)) from product)as float) )* 100 as ratio 

 --- 57% of stockout product

select  distinct p.product_name from product p
join inventory i on p.product_id = i.product_id
join store s  on  s.store_id=i.store_id
where i.stock_on_hand = 0

 select sum(s.units) as totalunits,p.product_name  from sales s
 join product p on s.product_id=p.product_id
 group by p.product_name
 order by sum(s.units) desc

 ----because of this we facing churn and lost of revenue
 --- on demand product are  out of stock
 --recommendatio :Set an automated reorder point (ROP) that triggers a new purchase order when inventory falls to a predetermined level.
 
