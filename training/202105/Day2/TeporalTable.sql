create database dbTemporal
--�D CDC �q ldf �z�L log reader Ū���������� system table
alter database dbTemporal set recovery simple
go
use dbTemporal
go

/*
--�f�t WITH (SYSTEM_VERSIONING = ON)
--�Ѩt���������ͰO���ɶ����{��������ƪ�
create table tbOrg
(
    PK int IDENTITY NOT NULL PRIMARY KEY,
    c1 nvarchar(500),
    StartTime datetime2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
    DueTime datetime2 GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,  
    PERIOD FOR SYSTEM_TIME (StartTime,DueTime)  
)
WITH (SYSTEM_VERSIONING = ON) --�t�Φ۰ʲ��� Temporal �Ϊ� History ��ƪ�A�W������ MSSQL_TemporalHistoryFor_<�t�νs��>
                              --�C���إߡA��ƪ�W�ٳ����@�ˡA���n���@
go
*/

--�ۦ���w�O���ɶ����{��������ƪ�
create table tbOrg
(
    PK int IDENTITY NOT NULL PRIMARY KEY,
    c1 nvarchar(500),
    StartTime datetime2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL, --Hidden ����r�|���óo�����
    DueTime datetime2 GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,  
    PERIOD FOR SYSTEM_TIME (StartTime,DueTime)  
)
go
create table tbOrg2
(
    PK int IDENTITY NOT NULL PRIMARY KEY,
    c1 nvarchar(500),
    StartTime datetime2 GENERATED ALWAYS AS ROW START  NOT NULL,
    DueTime datetime2 GENERATED ALWAYS AS ROW END  NOT NULL,  
    PERIOD FOR SYSTEM_TIME (StartTime,DueTime)  
)
go

--�ݤ��� Hidden
select * from tbOrg

select * from tbOrg2

alter table tbOrg add c2 int

insert tbOrg2(c1) values('a')
select * from tbOrg2

insert tbOrg(c1) values('a')
go 100

update tbOrg set c1='abc'

CREATE TABLE tbOrgHistory(
	PK int NOT NULL,
	c1 nvarchar(500) NULL,
	StartTime datetime2(7) NOT NULL,
	DueTime datetime2(7) NOT NULL
) 
go

ALTER TABLE tbOrg SET (SYSTEM_VERSIONING = ON
 (HISTORY_TABLE =  dbo.tbOrgHistory) 
)
go

ALTER TABLE tbOrg SET (SYSTEM_VERSIONING = OFF)

select * from tbOrgHistory

select *,StartTime,DueTime from tbOrg for system_time all


--�d�� temporal ��ƪ�
select name,object_id,temporal_type,temporal_type_desc,history_table_id from sys.tables
select * from sys.columns where object_id=object_id('tbOrg')

--------------------------------------------------------------------------------------------------------------------
--�z�L for system_time �d�߬Y�Ӯɶ��I����ƪ��e
--�e�{���v��ƪ��A�ŦX for system_time as �� from to �ɶ��W�d���̫���{�O��
insert tbOrg(c1) values('a'),('b')
select '�s�W�ⵧ�����A��U��ƻP���v���'
select * from tbOrg
select * from tbOrgHistory
waitfor delay '00:00:01'
declare @t datetime=dateadd(hour,-8,getdate()) --�n�� UTC �ɶ�
update tbOrg set c1+=',' + convert(char(8),convert(time(0),getdate()))
waitfor delay '00:00:03'
delete tbOrg where pk=1
waitfor delay '00:00:03'
insert tbOrg(c1) values('c')

select '�ק�R��������A��U��ƻP���v���'
--�z�L FOR SYSTEM_TIME �l�y�ݤ@�q�ɶ���������ܤ�
select N'��U���' [��U���],* from tbOrg
select N'���v���' [���v���],* from tbOrgHistory

-- AS OF�G StartTime <= @t AND DueTime > @t
--�b�Ӯɶ��I���s�b����������
select 'FOR SYSTEM_TIME AS OF ' + convert(varchar(100),@t,14) [FOR SYSTEM_TIME AS OF                                                    ]
select N'���v���' [���v���],* from tbOrgHistory
SELECT @t,* FROM tbOrg FOR SYSTEM_TIME AS OF @t


declare @t2 datetime=dateadd(hour,-8,getdate())
select 'FOR SYSTEM_TIME AS OF ' + convert(varchar(100),@t2,14) [FOR SYSTEM_TIME AS OF                                                    ]
SELECT @t2,* FROM tbOrg FOR SYSTEM_TIME AS OF @t2

--FROM TO�GStartTime < @t2 AND DueTime > @t3�A
--�ɶ��d�򤺴��g�s�b���Ҧ����������A���]�t��ɡA
--�ҥH�����ͦ��ɶ��p��d�ߺI��d��A�Φ��`�ɶ��j��d�߰_�l�d��
--�N��Ӭ��������b�d�򤺴����L
declare @t3 datetime=dateadd(second,-6,@t2)
select 'FOR SYSTEM_TIME FROM ' + convert(varchar(100),@t3,14) + ' to ' +  convert(varchar(100),@t2,14) [FOR SYSTEM_TIME FROM TO                                                    ]
select N'���v���' [���v���],* from tbOrgHistory
SELECT @t3,@t2,* FROM tbOrg FOR SYSTEM_TIME FROM @t3 to @t2

--BETWEEN AND�GStartTime <= @t2 AND DueTime > =@t3
--�P From to �ۦP�A�����������_�l�ɶ��]�t���
select 'FOR SYSTEM_TIME BETWEEN ' + convert(varchar(100),@t3,14) + ' and ' +  convert(varchar(100),@t2,14) [FOR SYSTEM_TIME BETWEEN AND                                                    ]
select N'���v���' [���v���],* from tbOrgHistory
SELECT @t3,@t2,* FROM tbOrg FOR SYSTEM_TIME BETWEEN @t3 AND @t2

--CONTAINED IN�GStartTime>= @t4 AND DueTime<= @t2
--�b�d�߮ɶ��q���_�l�P�פ���������A
--��U�����������ɶ����O�L���j�A�ҥH���|�]�t�b contained in ��
declare @t4 datetime=dateadd(second, -60,@t) 
select 'FOR SYSTEM_TIME CONTAINED IN(' + convert(varchar(100),@t4,14) + ' , ' +  convert(varchar(100),@t2,14) + ')' [FOR SYSTEM_TIME CONTAINED IN                                                    ]
select N'���v���' [���v���],* from tbOrgHistory
SELECT @t4,@t2,* FROM tbOrg FOR SYSTEM_TIME CONTAINED IN ( @t4,@t2)

go

--------------------------------------------------------------------------------------------------------------------
--�ק��ƪ��c
alter table tbOrg add c12 int
/*
--����SYSTEM_VERSIONING
ALTER TABLE tbOrg SET (SYSTEM_VERSIONING = OFF)

--�ק�Current��ƪ����c�y�z
alter table tbOrg add c12 int

--�ק�History��ƪ����c�y�z
ALTER TABLE tbOrgHistory ADD c12 int
 
--�ҥ�SYSTEM_VERSIONING �ñN���e�� temporal ��ƪ�]�w���ק�᪺ History ��ƪ�
ALTER TABLE tbOrg SET (SYSTEM_VERSIONING = ON
 (HISTORY_TABLE =  dbo.tbOrgHistory ) 
)

--�������ƾ��{�̵M�٦b
select * from tbOrg
select * from tbOrgHistory
*/
GO

--------------------------------------------------------------------------------------------------------------------
--�ק���v��ƪ��e
--�����ק�|����
select * from tbOrgHistory

/*
�T�� 13561�A�h�� 16�A���A 1�A�� 160
�L�k��s�ɺA�O����ƪ� 'dbTemporal.dbo.tbOrgHistory' ������ƦC�C
*/
update tbOrgHistory set c12=1

/*
�T�� 13559�A�h�� 16�A���A 1�A�� 153
�L�k�b�ȮɰO����ƪ� 'dbTemporal.dbo.tbOrgHistory' �����J��ƦC�C
*/
insert tbOrgHistory(PK, c1, StartTime, DueTime, c12) values(100,'abcd','00010101','99991231',1)

/*
�T�� 13560�A�h�� 16�A���A 1�A�� 151
�L�k�q�ȮɰO����ƪ� 'dbTemporal.dbo.tbOrgHistory' ���R����ƦC�C
*/
delete tbOrgHistory

--�_�����Y��i�H�����R���A�Y�n�� Audit ����A�o�ݭn�Ҽ{
ALTER TABLE tbOrg SET (SYSTEM_VERSIONING = OFF)
go
delete tbOrgHistory
go
ALTER TABLE tbOrg SET (SYSTEM_VERSIONING = ON
 (HISTORY_TABLE =  dbo.tbOrgHistory ) 
)

select * from tbOrg
select * from tbOrgHistory

--------------------------------------------------------------------------------------------------------------------
--��Ұ� temproral table�A�L�k truncate table
/*
�T�� 13545�A�h�� 16�A���A 1�A�� 103
�]���Ѩt�γ]�w��������ƪ��䴩�I�_�ʧ@�A�ɭP��ƪ� 'dbTemporal.dbo.tbOrg' ���I�_�ʧ@���ѡC
*/
ALTER TABLE tbOrg SET (SYSTEM_VERSIONING = OFF)
truncate table tbOrg
truncate table tbOrgHistory
/*
�T�� 13539�A�h�� 15�A���A 1�A�� 129
�]���O����ƪ� 'tbOrgHistory' ���H�ⳡ���W�ٮ榡���w�A�ҥH�L�k�N SYSTEM_VERSIONING �]�� ON�C
*/
ALTER TABLE tbOrg SET (SYSTEM_VERSIONING = ON
 (HISTORY_TABLE =  dbo.tbOrgHistory ) 
)


/*
�T�� 13552�A�h�� 16�A���A 1�A�� 54
�b��ƪ� 'dbTemporal.dbo.tbOrg' �W�i�������ƪ�@�~���ѡA�]���b�t�γ]�w�������Ȧs��ƪ�W�A���䴩���@�~�C
*/
drop table tbOrg

IF ((SELECT temporal_type FROM SYS.TABLES WHERE object_id = OBJECT_ID('tbOrg', 'U')) = 2)
BEGIN
    ALTER TABLE tbOrg SET (SYSTEM_VERSIONING = OFF)
END

GO

drop table tbOrg
drop table tbOrgHistory

--�f�t Audit
USE [master] 
GO 
CREATE SERVER AUDIT [Audit01] 
TO FILE 
(    FILEPATH = N'C:\temp' 
    ,MAXSIZE = 0 MB 
    ,MAX_ROLLOVER_FILES = 2147483647 
    ,RESERVE_DISK_SPACE = OFF 
) 
WITH 
(    QUEUE_DELAY = 1000 
    ,ON_FAILURE = CONTINUE 
) 
GO 
alter server audit [Audit01] with(state=on) 
go

create database dbTemporal 
--�D CDC �q ldf �z�L log reader Ū���������� system table 
alter database dbTemporal set recovery simple 
go 
use dbTemporal 
go

--�ۦ���w�O���ɶ����{��������ƪ� 
create table tbOrg 
( 
    PK int IDENTITY NOT NULL PRIMARY KEY, 
    c1 nvarchar(500), 
    StartTime datetime2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL, --Hidden ����r�|���óo����� 
    DueTime datetime2 GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,  
    PERIOD FOR SYSTEM_TIME (StartTime,DueTime)  
) 
go

CREATE TABLE tbOrgHistory( 
    PK int NOT NULL, 
    c1 nvarchar(500) NULL, 
    StartTime datetime2(7) NOT NULL, 
    DueTime datetime2(7) NOT NULL 
) 
go

ALTER TABLE tbOrg SET (SYSTEM_VERSIONING = ON 
(HISTORY_TABLE =  dbo.tbOrgHistory) 
) 
go

CREATE DATABASE AUDIT SPECIFICATION [DatabaseAuditSpecification01] 
FOR SERVER AUDIT [Audit01] 
ADD(SELECT,INSERT,UPDATE,DELETE,EXECUTE ON database::dbTemporal BY public) 
WITH (STATE = ON) 
GO

--�Y�Ӯɶ��I�d�߻y�k�ݨ쪺��� 
create proc spGetSnapshot @sql nvarchar(max),@time datetime2(7) 
as 
    set @sql +=' for system_time as of ''' + convert(varchar(100),dateadd(hour,-8,@time)) + '''' --�ন UTC �ɶ� 
    exec(@sql) 
go

-------------------------------------------------------- 
--Audit �f�t Temporal �˵��^�Ǫ���� 
insert tbOrg(c1) values('a') 
waitfor delay '00:00:01' 
declare @t datetime2(7)=sysdatetime() 
select * from tbOrg --�����ϥΪ̬d�� 
waitfor delay '00:00:01' 
update tbOrg set c1=c1 +'1' 
insert tbOrg(c1) values('d2') 
declare @sql nvarchar(max)

--Audit �]�O�� UTC �ɶ� 
SELECT top(1) @sql=statement 
FROM sys.fn_get_audit_file ('C:\temp\Audit*.sqlaudit',default,default) 
where event_time=dateadd(hour,-8,@t) and object_name='tbOrg'; 
select @sql 
exec spGetSnapshot @sql,@t

ALTER TABLE tbOrg SET (SYSTEM_VERSIONING = OFF) 
drop table tbOrg 
drop table tbOrgHistory

ALTER DATABASE AUDIT SPECIFICATION [DatabaseAuditSpecification01] 
WITH (STATE = OFF) 
GO 
DROP DATABASE AUDIT SPECIFICATION [DatabaseAuditSpecification01] 
GO
