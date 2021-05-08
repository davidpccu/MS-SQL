drop table if exists t
create table t(pk int identity primary key,c1 varchar(50))
go
insert t(c1) values('hello')
go
insert t(c1) select c1 from t
go 20

create index idx on t(c1)

insert t(c1) values('hi')

select * from t where c1='hi'
insert t(c1) values('hi1234')
select * from t where substring(c1,1,2)='hi' --索引掃描 (效能差)
select * from t where c1 like 'hi%'			-- 索引搜尋

alter table t add c2 as substring(c1,1,2)
create index idx2 on t(c2)
alter table t add c3 as getdate()
select * from t
create index idx3 on t(c3)


