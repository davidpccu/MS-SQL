create sequence s start with 1
select next value for s
go
drop table if exists t,t2
go
create table t(c1 int default(next value for s))
create table t2(c1 int default(next value for s))
go
insert t default values
insert t2 default values
go 10
select * from t
select * from t2


