use tempdb

create table t(c1 int,c2 int)
go
create or alter view vw 
as
	select * from t
go

alter table t add c3 int

select * from vw

exec sp_refreshview 'vw'

select * from vw
go
create or alter view vw 
as
	select * from t where c1<10
go

insert vw(c1,c2) values(100,100)

select * from vw
go

create or alter view vw 
as
	select * from t where c1<10
with check option
go

insert vw(c1,c2) values(101,101)

insert vw(c1,c2) values(1,101)

drop table if exists t2
create table t2(c11 int,c22 int)
go
create or alter view vw
as
	select c1,c2,c11,c22 from t join t2 on t.c1=t2.c11
go

insert vw(c1,c2) values(1,2)
insert vw(c11,c22) values(1,100)
select * from vw

insert vw(c1,c2,c11,c22) values(1,2,1,123)
go
create or alter trigger trg on vw
instead of insert
as
	insert t(c1,c2) select c1,c2 from inserted
	insert t2(c11,c22) select c11,c22 from inserted
go
insert vw(c1,c2,c11,c22) values(1,2,1,123)
select * from vw
