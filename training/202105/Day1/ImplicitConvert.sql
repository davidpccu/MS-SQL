select 1/2,1/2.,1+'1','1'+1,getdate()+1
use tempdb
drop table if exists t
create table t(c1 varchar(100))
go
insert t values(1)
go
insert t select c1 from t
go 20

select convert(varbinary(10),'中'), convert(varbinary(10),N'中'),'煊',N'煊'
select * from t where c1=N'1'
alter table t add c2 nvarchar(100)
update t set c2=N'a'
-- 執行計畫 col轉型 vs 傳入資料轉型
select * from t where c2='a'
select * from t where c2=getdate()
select * from t where c2=convert(varchar(20),getdate())

select cast(getdate() as varchar(50)),convert(varchar(50),getdate()),convert(varchar(50),getdate(),112)

select parse('NT$50' as money using 'zh-tw')
select cast('a' as int)
select try_cast('a' as int)


