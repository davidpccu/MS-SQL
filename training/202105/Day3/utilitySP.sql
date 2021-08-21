create or alter proc sp_a
as
	select 'hi',db_name(),* from tbA
go
select * from sys.objects where name='sp_a'
exec sp_MS_marksystemobject 'sp_a'

create table tbA(c1 int)
insert tbA values(1)

exec sp_A
