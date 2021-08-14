create sequence s as tinyint
start with 1
increment by 100
cycle
go

select next value for s
drop table if exists t
create table t(c1 int default(next value for s),c2 varchar(50))

insert t(c2) values('a')
select * from t

alter sequence s 
restart with 1 increment by 1

insert t(c2) values('b'),('c'),('d')
select * from t
