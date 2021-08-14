select 1/2,1/2., convert(varbinary(10),'¤¤' + N'¤¤')
drop table if exists t1
create table t1(c1 varchar(50),c2 int,c3 date)

select * from t1 where c2='123'
select * from t1 where c3='20210814'


select * from t1 where c1=convert(varchar(50),getdate(),123)
select * from t1 where c1=convert(varchar(50),123)
select * from t1 where c1=N'¤¤'
