use tempdb
create table t(c1 int identity)
go
create table t2(c1 int identity,c21 int)
go
create trigger trg on t
for insert
as
	insert t2(c21) select c1 from inserted
go
insert t2(c21) values(1)
go
insert t default values
select @@IDENTITY,SCOPE_IDENTITY()


drop trigger trg

alter table t add c2 varchar(50)
insert t(c2) output inserted.c1 values('hello')
insert t output inserted.c1 default values

select * from t




