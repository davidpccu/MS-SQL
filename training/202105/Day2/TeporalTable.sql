create database dbTemporal
--非 CDC 從 ldf 透過 log reader 讀交易紀錄放到 system table
alter database dbTemporal set recovery simple
go
use dbTemporal
go

/*
--搭配 WITH (SYSTEM_VERSIONING = ON)
--由系統幫忙產生記錄時間歷程的對應資料表
create table tbOrg
(
    PK int IDENTITY NOT NULL PRIMARY KEY,
    c1 nvarchar(500),
    StartTime datetime2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
    DueTime datetime2 GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,  
    PERIOD FOR SYSTEM_TIME (StartTime,DueTime)  
)
WITH (SYSTEM_VERSIONING = ON) --系統自動產生 Temporal 用的 History 資料表，名稱類似 MSSQL_TemporalHistoryFor_<系統編號>
                              --每次建立，資料表名稱都不一樣，不好維護
go
*/

--自行指定記錄時間歷程的對應資料表
create table tbOrg
(
    PK int IDENTITY NOT NULL PRIMARY KEY,
    c1 nvarchar(500),
    StartTime datetime2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL, --Hidden 關鍵字會隱藏這個欄位
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

--看不到 Hidden
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


--查詢 temporal 資料表
select name,object_id,temporal_type,temporal_type_desc,history_table_id from sys.tables
select * from sys.columns where object_id=object_id('tbOrg')

--------------------------------------------------------------------------------------------------------------------
--透過 for system_time 查詢某個時間點的資料表內容
--呈現歷史資料表中，符合 for system_time as 或 from to 時間規範的最後歷程記錄
insert tbOrg(c1) values('a'),('b')
select '新增兩筆紀錄，當下資料與歷史資料'
select * from tbOrg
select * from tbOrgHistory
waitfor delay '00:00:01'
declare @t datetime=dateadd(hour,-8,getdate()) --要用 UTC 時間
update tbOrg set c1+=',' + convert(char(8),convert(time(0),getdate()))
waitfor delay '00:00:03'
delete tbOrg where pk=1
waitfor delay '00:00:03'
insert tbOrg(c1) values('c')

select '修改刪除紀錄後，當下資料與歷史資料'
--透過 FOR SYSTEM_TIME 子句看一段時間內的資料變化
select N'當下資料' [當下資料],* from tbOrg
select N'歷史資料' [歷史資料],* from tbOrgHistory

-- AS OF： StartTime <= @t AND DueTime > @t
--在該時間點正存在的版本紀錄
select 'FOR SYSTEM_TIME AS OF ' + convert(varchar(100),@t,14) [FOR SYSTEM_TIME AS OF                                                    ]
select N'歷史資料' [歷史資料],* from tbOrgHistory
SELECT @t,* FROM tbOrg FOR SYSTEM_TIME AS OF @t


declare @t2 datetime=dateadd(hour,-8,getdate())
select 'FOR SYSTEM_TIME AS OF ' + convert(varchar(100),@t2,14) [FOR SYSTEM_TIME AS OF                                                    ]
SELECT @t2,* FROM tbOrg FOR SYSTEM_TIME AS OF @t2

--FROM TO：StartTime < @t2 AND DueTime > @t3，
--時間範圍內曾經存在的所有紀錄版本，不包含邊界，
--所以紀錄生成時間小於查詢截止範圍，或死亡時間大於查詢起始範圍
--代表該紀錄版本在範圍內曾活過
declare @t3 datetime=dateadd(second,-6,@t2)
select 'FOR SYSTEM_TIME FROM ' + convert(varchar(100),@t3,14) + ' to ' +  convert(varchar(100),@t2,14) [FOR SYSTEM_TIME FROM TO                                                    ]
select N'歷史資料' [歷史資料],* from tbOrgHistory
SELECT @t3,@t2,* FROM tbOrg FOR SYSTEM_TIME FROM @t3 to @t2

--BETWEEN AND：StartTime <= @t2 AND DueTime > =@t3
--與 From to 相同，但紀錄版本起始時間包含邊界
select 'FOR SYSTEM_TIME BETWEEN ' + convert(varchar(100),@t3,14) + ' and ' +  convert(varchar(100),@t2,14) [FOR SYSTEM_TIME BETWEEN AND                                                    ]
select N'歷史資料' [歷史資料],* from tbOrgHistory
SELECT @t3,@t2,* FROM tbOrg FOR SYSTEM_TIME BETWEEN @t3 AND @t2

--CONTAINED IN：StartTime>= @t4 AND DueTime<= @t2
--在查詢時間段內起始與終止的紀錄版本，
--當下紀錄的結束時間都是無限大，所以不會包含在 contained in 內
declare @t4 datetime=dateadd(second, -60,@t) 
select 'FOR SYSTEM_TIME CONTAINED IN(' + convert(varchar(100),@t4,14) + ' , ' +  convert(varchar(100),@t2,14) + ')' [FOR SYSTEM_TIME CONTAINED IN                                                    ]
select N'歷史資料' [歷史資料],* from tbOrgHistory
SELECT @t4,@t2,* FROM tbOrg FOR SYSTEM_TIME CONTAINED IN ( @t4,@t2)

go

--------------------------------------------------------------------------------------------------------------------
--修改資料表結構
alter table tbOrg add c12 int
/*
--停用SYSTEM_VERSIONING
ALTER TABLE tbOrg SET (SYSTEM_VERSIONING = OFF)

--修改Current資料表的結構描述
alter table tbOrg add c12 int

--修改History資料表的結構描述
ALTER TABLE tbOrgHistory ADD c12 int
 
--啟用SYSTEM_VERSIONING 並將先前的 temporal 資料表設定為修改後的 History 資料表
ALTER TABLE tbOrg SET (SYSTEM_VERSIONING = ON
 (HISTORY_TABLE =  dbo.tbOrgHistory ) 
)

--原先的資料歷程依然還在
select * from tbOrg
select * from tbOrgHistory
*/
GO

--------------------------------------------------------------------------------------------------------------------
--修改歷史資料表內容
--直接修改會失敗
select * from tbOrgHistory

/*
訊息 13561，層級 16，狀態 1，行 160
無法更新時態記錄資料表 'dbTemporal.dbo.tbOrgHistory' 中的資料列。
*/
update tbOrgHistory set c12=1

/*
訊息 13559，層級 16，狀態 1，行 153
無法在暫時記錄資料表 'dbTemporal.dbo.tbOrgHistory' 中插入資料列。
*/
insert tbOrgHistory(PK, c1, StartTime, DueTime, c12) values(100,'abcd','00010101','99991231',1)

/*
訊息 13560，層級 16，狀態 1，行 151
無法從暫時記錄資料表 'dbTemporal.dbo.tbOrgHistory' 中刪除資料列。
*/
delete tbOrgHistory

--斷掉關係後可以直接刪除，若要當 Audit 機制，這需要考慮
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
--當啟動 temproral table，無法 truncate table
/*
訊息 13545，層級 16，狀態 1，行 103
因為由系統設定版本的資料表不支援截斷動作，導致資料表 'dbTemporal.dbo.tbOrg' 的截斷動作失敗。
*/
ALTER TABLE tbOrg SET (SYSTEM_VERSIONING = OFF)
truncate table tbOrg
truncate table tbOrgHistory
/*
訊息 13539，層級 15，狀態 1，行 129
因為記錄資料表 'tbOrgHistory' 未以兩部分名稱格式指定，所以無法將 SYSTEM_VERSIONING 設為 ON。
*/
ALTER TABLE tbOrg SET (SYSTEM_VERSIONING = ON
 (HISTORY_TABLE =  dbo.tbOrgHistory ) 
)


/*
訊息 13552，層級 16，狀態 1，行 54
在資料表 'dbTemporal.dbo.tbOrg' 上進行卸除資料表作業失敗，因為在系統設定版本的暫存資料表上，不支援此作業。
*/
drop table tbOrg

IF ((SELECT temporal_type FROM SYS.TABLES WHERE object_id = OBJECT_ID('tbOrg', 'U')) = 2)
BEGIN
    ALTER TABLE tbOrg SET (SYSTEM_VERSIONING = OFF)
END

GO

drop table tbOrg
drop table tbOrgHistory

--搭配 Audit
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
--非 CDC 從 ldf 透過 log reader 讀交易紀錄放到 system table 
alter database dbTemporal set recovery simple 
go 
use dbTemporal 
go

--自行指定記錄時間歷程的對應資料表 
create table tbOrg 
( 
    PK int IDENTITY NOT NULL PRIMARY KEY, 
    c1 nvarchar(500), 
    StartTime datetime2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL, --Hidden 關鍵字會隱藏這個欄位 
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

--某個時間點查詢語法看到的資料 
create proc spGetSnapshot @sql nvarchar(max),@time datetime2(7) 
as 
    set @sql +=' for system_time as of ''' + convert(varchar(100),dateadd(hour,-8,@time)) + '''' --轉成 UTC 時間 
    exec(@sql) 
go

-------------------------------------------------------- 
--Audit 搭配 Temporal 檢視回傳的資料 
insert tbOrg(c1) values('a') 
waitfor delay '00:00:01' 
declare @t datetime2(7)=sysdatetime() 
select * from tbOrg --模擬使用者查詢 
waitfor delay '00:00:01' 
update tbOrg set c1=c1 +'1' 
insert tbOrg(c1) values('d2') 
declare @sql nvarchar(max)

--Audit 也是用 UTC 時間 
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
