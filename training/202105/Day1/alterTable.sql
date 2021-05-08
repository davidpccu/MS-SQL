use tempdb

drop table if exists t
create table t(c1 int)
go
create view vw
as
	select * from t
go
alter table t add c2 int
go
select * from vw
select * from t
exec sp_refreshview 'vw'
select * from vw



