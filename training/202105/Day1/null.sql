use northwind
go
select * from customers where Region='BC'
select * from customers where Region = null

create table #t(c1 int)
insert #t values(1),(null),(3)
select count(*),count(c1),avg(c1),avg(isnull(c1,0)) from #t
