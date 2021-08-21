use tempdb

create table #t(c1 int)
insert #t values(1)
go
create or alter proc sp
as
	insert #t values(2)
	select * from #t
	exec sp2

go

create or alter proc sp2
as
	insert #t values(3)
	create table #t2(c1 int)
	insert #t2 values(1)
go
exec sp
exec sp2
select * from #t
select * from #t2
drop table #t

