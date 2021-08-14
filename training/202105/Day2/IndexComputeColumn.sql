drop table if exists t1

create table t1(c1 int identity primary key,
c2 varchar(100),c3 datetime2(7) default(sysdatetime()))

insert t1(c2) values('abcde'),('fghij'),('klmno')

insert t1(c2) select c2 from t1
go 8

insert t1(c2) values('abcccde')

create index idx on t1(c2)

select * from t1 where c2='abcccde'

select * from t1 where substring(c2,3,3)='ccc'

alter table t1 add c4 as substring(c2,3,3)

create index idx2 on t1(c4)


