drop table if exists t,t1

create table t(pk int primary key)
create table t1(pk int,c1 int default(-1))

alter table t1 add constraint fk foreign key(c1) references t(pk) 
on delete cascade
on update set default
go
--
insert t values(-1),(1),(2)
insert t1 values(1,1),(2,2)

select * from t
select * from t1

--
delete t where pk=1
update t set pk=3 where pk=2

select * from t
select * from t1

--
alter table t1 nocheck constraint all
alter table t1 with check check constraint all

update t1 set c1=-1 where c1=1