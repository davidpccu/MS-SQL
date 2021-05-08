drop table if exists t
create table t(c1 int identity,c2 uniqueidentifier default(newid()),c3 uniqueidentifier default(newsequentialid()))
go
insert t default values
go 20

select * from t order by 2
select * from t order by 3

select newid()
select NEWSEQUENTIALID()
