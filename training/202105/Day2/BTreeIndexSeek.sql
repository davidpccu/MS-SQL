drop table if exists  t
create table t(c1 int,c2 varchar(50))

insert t(c1) values(1)
go
insert t(c1) select c1+1 from t
go 20

insert t(c1) values(11124)


set statistics io, time on

/*
資料表 't'。掃描計數 1，邏輯讀取 1686，實體讀取 0，頁面伺服器讀取 0，讀取前讀取 0，頁面伺服器讀取前讀取 0，LOB 邏輯讀取 0，LOB 實體讀取 0，LOB 頁面伺服器讀取 0，LOB 讀取前讀取 0，LOB 頁面伺服器讀取前讀取 0。

 SQL Server 執行次數: 
，CPU 時間 = 78 ms，經過時間 = 74 ms。
*/
select * from t where c1=123

create index idx on t(c1)

select * from sys.dm_db_index_physical_stats(2,object_id('t'),null,null,'detailed')
/*
資料表 't'。掃描計數 1，邏輯讀取 4，實體讀取 0，頁面伺服器讀取 0，讀取前讀取 0，頁面伺服器讀取前讀取 0，LOB 邏輯讀取 0，LOB 實體讀取 0，LOB 頁面伺服器讀取 0，LOB 讀取前讀取 0，LOB 頁面伺服器讀取前讀取 0。

 SQL Server 執行次數: 
，CPU 時間 = 0 ms，經過時間 = 0 ms。
*/
select * from t where c1=123
select count(*) from t

insert t(c1) select c1+1 from t
go 4
/*
資料表 't'。掃描計數 1，邏輯讀取 5，實體讀取 0，頁面伺服器讀取 0，讀取前讀取 0，頁面伺服器讀取前讀取 0，LOB 邏輯讀取 0，LOB 實體讀取 0，LOB 頁面伺服器讀取 0，LOB 讀取前讀取 0，LOB 頁面伺服器讀取前讀取 0。

 SQL Server 執行次數: 
，CPU 時間 = 0 ms，經過時間 = 0 ms。
*/


select count(*),c1 from t group by c1
select * from t where c1=1124
select c1 from t where c1=16
