drop table if exists t1
create table t1(c1 int not null,c2 int)

insert t1(c1) values(1),(10),(3),(7),(5)

delete t1 where c1=3

insert t1(c1) values(8)

select * from t1

--
create clustered index idx on t1(c1)

drop index idx on t1

select * from t1

--
alter table t1 add constraint pk primary key(c1)

select * from sys.indexes where object_id=object_id('t1')

alter table t1 drop constraint pk


alter table t1 add constraint pk primary key nonclustered(c1)

create clustered index idx2 on t1(c2)

select * from sys.indexes where object_id=object_id('t1')

