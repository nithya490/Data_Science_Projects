use Allo

select* from FacebookRaw
select * from GoogleRaw

select column_name,data_type
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='FacebookRaw'

--REMOVE NULL VALUES
delete from FacebookRaw
where isnumeric(Impressions)=0

delete from GoogleRaw
where ISNUMERIC(Impressions)=0

---CHANGE DATA TYPE

alter table FacebookRaw
alter column Date date

alter table FacebookRaw
alter column Clicks_Traffic int 

alter table FacebookRaw
alter column impressions int

alter table FacebookRaw
alter column leads int

alter table FacebookRaw
alter column CPL_INR money

alter table FacebookRaw
alter column Cost_INR money

alter table FacebookRaw
alter column CPC_INR money

alter table FacebookRaw
alter column Call_Conversion int

alter table FacebookRaw
alter column Type_of_Call_Online int

alter table FacebookRaw
alter column Type_of_Call_Offline int

select column_name,data_type
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='FacebookRaw'

---GOOGLE 

select * from GoogleRaw
select column_name,data_type
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='GoogleRaw'

alter table GoogleRaw
alter column Date date

alter table GoogleRaw
alter column Clicks_Traffic int 

alter table GoogleRaw
alter column impressions int

alter table GoogleRaw
alter column leads int

alter table GoogleRaw
alter column CPL_INR money

alter table GoogleRaw
alter column Cost_INR money

alter table GoogleRaw
alter column CPC_INR money

alter table GoogleRaw
alter column Calls int

alter table GoogleRaw
alter column Type_of_Call_Online int

alter table GoogleRaw
alter column Type_of_Call_Offline int

alter table GoogleRaw
alter column CAC money

----DUPLICATES
 
with Duplrows as(select *, row_number() over(partition by Date,Campaign_Name,Ad_Set_Name order by Date) as row_num
from FacebookRaw )

select *  from Duplrows
where row_num>1

with Duplrows1 as(select *, row_number() over(partition by Date,Campaign_Name,Ad_Set_Name order by Date) as row_num
from GoogleRaw )

select * from Duplrows1
where row_num>1

select* from FacebookRaw
select * from GoogleRaw

---no duplicates

---ANALYSIS--------

--MANUPULATION
alter table  FacebookRaw
add Revenue_from_online money , Revenue_from_Offline money

update FacebookRaw set Revenue_from_online= Type_of_Call_Online*1200
update FacebookRaw set Revenue_from_Offline= Type_of_Call_Offline*2000

alter table  GoogleRaw
add Revenue_from_online money , Revenue_from_Offline money

update GoogleRaw set Revenue_from_online= Type_of_Call_Online*1200
update GoogleRaw set Revenue_from_Offline= Type_of_Call_Offline*2000

update GoogleRaw set CTR=CTR*100  
update GoogleRaw set Traffic_to_Lead=Traffic_to_Lead*100
update GoogleRaw set Lead_to_Call= Lead_to_Call*1200

update FacebookRaw set CTR=CTR*100
update FacebookRaw set Traffic_to_Lead=Traffic_to_Lead*100
update FacebookRaw set Lead_to_Call= Lead_to_Call*1200

---WEEKDAY  performance 
--FACEBOOK
select DATENAME(weekday,Date) weeks,sum(Type_of_Call_Online) calls,SUM(Revenue_from_online) onlineRev from  FacebookRaw
group by DATENAME(WEEKDAY,Date)
order by SUM(Revenue_from_online) desc 

select DATENAME(weekday,Date) weeks,SUM(Type_of_Call_Offline) calls,SUM(Revenue_from_Offline) offlineRev from  FacebookRaw
group by DATENAME(WEEKDAY,Date)
order by SUM(Revenue_from_Offline) desc 

--GOOGLE
select DATENAME(weekday,Date) weeks,sum(Type_of_Call_Online) calls,SUM(Revenue_from_online) onlineRev from  GoogleRaw
group by DATENAME(WEEKDAY,Date)
order by SUM(Revenue_from_online) desc

select DATENAME(weekday,Date) weeks,SUM(Type_of_Call_Offline) calls,SUM(Revenue_from_Offline) offlineRev from  GoogleRaw
group by DATENAME(WEEKDAY,Date)
order by SUM(Revenue_from_Offline) desc 

----PLATFORM PERFORMANCE 
select SUM(f.Impressions) Fimpression,SUM(f.Clicks_Traffic) Fclicks,SUM(f.Cost_INR) FCOST,SUM(f.Call_Conversion) FCALL,avg(f.CTR) FCTR,avg(f.Traffic_to_Lead)Flead,avg(f.Lead_To_call) FLeadcall,SUM(f.Leads) Fleads,SUM(f.Revenue_from_Offline+f.Revenue_from_online)FRev,
SUM(g.Impressions) Gimpression,SUM(g.Clicks_Traffic) Gclicks,SUM(g.CTR) GCTR,sum(g.Cost_INR) Gcost,SUM(g.Calls) Gcall,avg(g.CTR) GCTR,avg(g.Traffic_to_Lead)Glead,avg(g.Lead_To_call) GLeadcall,SUM(g.Leads) Gleads ,SUM(g.Revenue_from_Offline+g.Revenue_from_online)GRev from FacebookRaw f
join GoogleRaw g on g.Date =f.Date


select  SUM(Type_of_Call_Offline) no_of_cals, SUM(Revenue_from_Offline)  rev from FacebookRaw ---29.10lakh, 1,455
select sum(Type_of_Call_Online) no_of_cals,SUM(Revenue_from_online) rev from FacebookRaw--44.71lakh, 3,726
select  SUM(Type_of_Call_Offline) no_of_cals, SUM(Revenue_from_Offline)  rev from GoogleRaw ---52.44lakh, 2,622
select sum(Type_of_Call_Online) no_of_cals,SUM(Revenue_from_online) rev from GoogleRaw--31.56 lakh, 2,630


--CAMPAIN PERFORMANCE 

select SUM(f.Impressions) Fimpression,SUM(f.Clicks_Traffic) Fclicks,SUM(f.Cost_INR) FCOST,SUM(f.Call_Conversion) FCALL,max(f.CTR) FCTR,max(f.Traffic_to_Lead)Flead,max(f.Lead_To_call) FLeadcall,SUM(f.Leads) Fleads,SUM(f.Revenue_from_Offline+f.Revenue_from_online)FRev,
SUM(g.Impressions) Gimpression,SUM(g.Clicks_Traffic) Gclicks,SUM(g.CTR) GCTR,sum(g.Cost_INR) Gcost,SUM(g.Calls) Gcall,max(g.CTR) GCTR,max(g.Traffic_to_Lead)Glead,max(g.Lead_To_call) GLeadcall,SUM(g.Leads) Gleads ,SUM(g.Revenue_from_Offline+g.Revenue_from_online)GRev from FacebookRaw f
join GoogleRaw g on g.Date =f.Date

select  f.Campaign_Name,,SUM(f.Clicks_Traffic) clicks,SUM(f.Cost_INR) cost,SUM(f.Leads) leads,SUM(f.Call_Conversion) calls,SUM(f.Type_of_Call_Online) online,SUM(f.Revenue_from_online) onlineREV,
sum(f.Type_of_Call_Offline) offline,sum(f.Revenue_from_Offline) offlineREV ,max(f.CTR) FCTR,max(f.Traffic_to_Lead)Flead,max(f.Lead_To_call) FLeadcall,SUM(f.Leads) Fleads,SUM(f.Revenue_from_Offline+f.Revenue_from_online)FRev from FacebookRaw f
group by f.Campaign_Name

select gg.Campaign_Name ,SUM(gg.Clicks_Traffic) clicks,SUM(gg.Cost_INR) cost,SUM(gg.Leads) leads,SUM(gg.Calls)calls,SUM(gg.Type_of_Call_Online) online,SUM(gg.Revenue_from_online) onlineREV,sum(gg.Type_of_Call_Offline) offline,
sum(gg.Revenue_from_Offline) offlineREV ,max(gg.CTR) GCTR,max(gg.Traffic_to_Lead)Glead,max(gg.Lead_To_call) GLeadcall,SUM(gg.Leads) Gleads ,SUM(gg.Revenue_from_Offline+gg.Revenue_from_online)GRev
from GoogleRaw gg 
group by gg.Campaign_Name 


---Add set PERFORMANCE
select  f.Ad_Set_Name,SUM(f.Clicks_Traffic) clicks,SUM(f.Cost_INR) cost,SUM(f.Leads) leads,SUM(f.Call_Conversion) calls,SUM(f.Type_of_Call_Online) online,SUM(f.Revenue_from_online) onlineREV,
sum(f.Type_of_Call_Offline) offline,sum(f.Revenue_from_Offline) offlineREV ,max(f.CTR) FCTR,max(f.Traffic_to_Lead)Flead,max(f.Lead_To_call) FLeadcall,SUM(f.Leads) Fleads,SUM(f.Revenue_from_Offline+f.Revenue_from_online)FRev from FacebookRaw f
group by f.Ad_Set_Name

select gg.Ad_Set_Name ,SUM(gg.Clicks_Traffic) clicks,SUM(gg.Cost_INR) cost,SUM(gg.Leads) leads,SUM(gg.Calls)calls,SUM(gg.Type_of_Call_Online) online,SUM(gg.Revenue_from_online) onlineREV,sum(gg.Type_of_Call_Offline) offline,
sum(gg.Revenue_from_Offline) offlineREV ,max(gg.CTR) GCTR,max(gg.Traffic_to_Lead)Glead,max(gg.Lead_To_call) GLeadcall,SUM(gg.Leads) Gleads ,SUM(gg.Revenue_from_Offline+gg.Revenue_from_online)GRev
from GoogleRaw gg 
group by gg.Ad_Set_Name




select  f.Campaign_Name,f.Ad_Set_Name,SUM(f.Clicks_Traffic) clicks,SUM(f.Cost_INR) cost,SUM(f.Leads) leads,SUM(f.Call_Conversion) calls,SUM(f.Type_of_Call_Online) online,SUM(f.Revenue_from_online) onlineREV,
sum(f.Type_of_Call_Offline) offline,sum(f.Revenue_from_Offline) offlineREV ,max(f.CTR) FCTR,max(f.Traffic_to_Lead)Flead,max(f.Lead_To_call) FLeadcall,SUM(f.Leads) Fleads,SUM(f.Revenue_from_Offline+f.Revenue_from_online)FRev from FacebookRaw f
group by f.Campaign_Name,f.Ad_Set_Name

select gg.Campaign_Name,gg.Ad_Set_Name ,SUM(gg.Clicks_Traffic) clicks,SUM(gg.Cost_INR) cost,SUM(gg.Leads) leads,SUM(gg.Calls)calls,SUM(gg.Type_of_Call_Online) online,SUM(gg.Revenue_from_online) onlineREV,sum(gg.Type_of_Call_Offline) offline,
sum(gg.Revenue_from_Offline) offlineREV ,max(gg.CTR) GCTR,max(gg.Traffic_to_Lead)Glead,max(gg.Lead_To_call) GLeadcall,SUM(gg.Leads) Gleads ,SUM(gg.Revenue_from_Offline+gg.Revenue_from_online)GRev
from GoogleRaw gg 
group by gg.Campaign_Name ,gg.Ad_Set_Name


----BENCH MARK ANALYSIS

select MIN(CTR) minCTR,avg(CTR) avgCTR,MAX(CTR) maxCTR, min(Traffic_to_Lead) minLEAD,AVG(Traffic_to_Lead) avgLEAD,max(Traffic_to_Lead) maxLEAD,min(Lead_To_Call) minCALL,AVG(Lead_To_Call) avgCALL,max(Lead_To_call) maxCALL from FacebookRaw
select MIN(CTR) minCTR,avg(CTR) avgCTR,MAX(CTR) maxCTR, min(Traffic_to_Lead) minLEAD,AVG(Traffic_to_Lead) avgLEAD,max(Traffic_to_Lead) maxLEAD,min(Lead_To_Call) minCALL,AVG(Lead_To_Call) avgCALL,max(Lead_To_call) maxCALL from GoogleRaw


select DATENAME(weekday,Date) weeks,sum(Call_Conversion) calls from  FacebookRaw
group by DATENAME(WEEKDAY,Date)
order by sum(Call_Conversion) desc

select DATENAME(weekday,Date) weeks,sum(Calls) calls from  GoogleRaw
group by DATENAME(WEEKDAY,Date)
order by sum(calls) desc