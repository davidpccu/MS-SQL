use AdventureWorksDW2012

select * from [dbo].[FactInternetSales] s
join DimProduct p on s.ProductKey=p.ProductKey
--where p.ProductKey=1


select sum(unitprice),productkey
from FactInternetSales group by ProductKey
go

create table #t123(c1 int)
go
create proc sp
as
	create table #t(c1 int)
	insert #t values(1)
	exec sp2
	select * from #t
	select * from #t2
go
create proc sp2
as
	insert #t values(2)
	create table #t2(c1 int)
	insert #t2 values(1)
go
exec sp
select * from tempdb.sys.objects

drop table #t123
