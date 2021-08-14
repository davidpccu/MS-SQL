drop table if exists t,t2

create table t(pk int identity,c2 varchar(10))

create table t2(pk int identity, c1 int)
go
create trigger trg on t
for insert
as 
	insert t2(c1) select pk from inserted
go

insert t2(c1) values(1)

insert t(c2) values('a')
select @@identity,SCOPE_IDENTITY()

declare @t table(pk int)
insert t(c2) output inserted.pk into @t
values('a'),('c'),('d')
declare @id int
select @id=max(pk) from @t
select @id

