drop table if exists  t
create table t(c1 int,c2 varchar(50))

insert t(c1) values(1)
go
insert t(c1) select c1+1 from t
go 20

insert t(c1) values(11124)


set statistics io, time on

/*
��ƪ� 't'�C���y�p�� 1�A�޿�Ū�� 1686�A����Ū�� 0�A�������A��Ū�� 0�AŪ���eŪ�� 0�A�������A��Ū���eŪ�� 0�ALOB �޿�Ū�� 0�ALOB ����Ū�� 0�ALOB �������A��Ū�� 0�ALOB Ū���eŪ�� 0�ALOB �������A��Ū���eŪ�� 0�C

 SQL Server ���榸��: 
�ACPU �ɶ� = 78 ms�A�g�L�ɶ� = 74 ms�C
*/
select * from t where c1=123

create index idx on t(c1)

select * from sys.dm_db_index_physical_stats(2,object_id('t'),null,null,'detailed')
/*
��ƪ� 't'�C���y�p�� 1�A�޿�Ū�� 4�A����Ū�� 0�A�������A��Ū�� 0�AŪ���eŪ�� 0�A�������A��Ū���eŪ�� 0�ALOB �޿�Ū�� 0�ALOB ����Ū�� 0�ALOB �������A��Ū�� 0�ALOB Ū���eŪ�� 0�ALOB �������A��Ū���eŪ�� 0�C

 SQL Server ���榸��: 
�ACPU �ɶ� = 0 ms�A�g�L�ɶ� = 0 ms�C
*/
select * from t where c1=123
select count(*) from t

insert t(c1) select c1+1 from t
go 4
/*
��ƪ� 't'�C���y�p�� 1�A�޿�Ū�� 5�A����Ū�� 0�A�������A��Ū�� 0�AŪ���eŪ�� 0�A�������A��Ū���eŪ�� 0�ALOB �޿�Ū�� 0�ALOB ����Ū�� 0�ALOB �������A��Ū�� 0�ALOB Ū���eŪ�� 0�ALOB �������A��Ū���eŪ�� 0�C

 SQL Server ���榸��: 
�ACPU �ɶ� = 0 ms�A�g�L�ɶ� = 0 ms�C
*/


select count(*),c1 from t group by c1
select * from t where c1=1124
select c1 from t where c1=16
