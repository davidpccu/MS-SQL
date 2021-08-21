create user u without login

drop table if exists t
create table t(c1 int,c2 int)
go
create or alter view vw
as
	select user [user],c1 from t
go

grant select on vw to u
insert t values(1,1)
exec('select * from vw') as user='u'

deny select on t to u

create user v without login
alter authorization on t to v
exec('select * from vw') as user='u'

exec('grant select on t to u') as user='v'

exec('select * from vw') as user='u'
