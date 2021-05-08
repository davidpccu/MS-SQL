create database dbPart
go
use dbPart
go

-- 實際的紀錄是：10/01/2013 <= 資料 < 9/01/2014
-- 多加一個 Partition 邊界(9/01/2013)，但實際放值的 10/01/2013 之後的紀錄
--避免想要轉移的 Partition 邊界是 null<= partition < 10/01/2013
--因我們將要移轉到tbArchive，
--其Partition 邊界是 9/01/2013<= partition < 10/01/2013
CREATE PARTITION FUNCTION pf(date)
AS RANGE RIGHT FOR VALUES (
'20130901','20131001', '20131101', '20131201',
'20140101', '20140201', '20140301', '20140401', 
'20140501', '20140601', '20140701', '20140801');
GO
--針對同一個 filegroup 建立 14 個 partition 存放區域
--上述 12 個切點，會有 13 個 Partition，但還會多建一個 Partition
--以存放多增切點時，下一個要使用的分割位置
--不一定要實際建立 14 個 filegroup
CREATE PARTITION SCHEME ps
AS PARTITION pf 
ALL TO ([PRIMARY]);
GO

DROP TABLE if exists [dbo].[tb];
GO

CREATE TABLE [dbo].[tb](
    [ID] [int] IDENTITY (1, 1) NOT NULL,
    [ProductID] [int] NOT NULL,
    [Quantity] [int] NOT NULL,
	[TransactionDate] [date] NOT NULL,
	CONSTRAINT pk PRIMARY KEY(ID,TransactionDate)
) ON ps (TransactionDate);

--Range分割資料表TransactionHistoryArchive
CREATE PARTITION FUNCTION pf2(date) 
AS RANGE RIGHT FOR VALUES ('20130901');
GO
 
--資料分割函數一切割後，就需要兩個 Filegroup，
--但因為要修改資料分割函數，需加上一個新的 Partition 邊界，
--所以一開始要先保留一個空間
--在此也可以使用 ALL TO ([PRIMARY])
--但故意示範兩種相同效果的寫法
CREATE PARTITION SCHEME ps2
AS PARTITION pf2
TO ([PRIMARY], [PRIMARY], [PRIMARY]);
GO
DROP TABLE if exists [dbo].[tbArchive];
GO
 
CREATE TABLE dbo.[tbArchive](
    [ID] [int] IDENTITY (1, 1) NOT NULL,
    [ProductID] [int] NOT NULL,
    [Quantity] [int] NOT NULL,
	[TransactionDate] [date] NOT NULL,
	CONSTRAINT pk_tbArchive PRIMARY KEY(ID,TransactionDate)
) ON ps2(TransactionDate);

truncate table tb
truncate table tbArchive
go
declare @i int=1,@j int=0,@k int=0
while @i<13
begin
	set @k=1+rand()*20
	while @j<@k
	begin
		insert tb values(@i*100+@j,@i*10,dateadd(month,@i,convert(smalldatetime,'20130801')))
		insert tbArchive values(@i,@i*10,'20130801')
		set @j+=1
	end
	set @j=0
	set @i+=1
end

--檢視原有的紀錄數，與等下轉移紀錄後做比較
SELECT COUNT(*) FROM tb
SELECT COUNT(*) FROM tbArchive
 
--檢查與 Partition 相關的 Meta data
SELECT $Partition.pf(TransactionDate) AS Partition, 
COUNT(*) AS [COUNT] FROM dbo.tb 
GROUP BY $partition.pf(TransactionDate)
ORDER BY Partition ;
 
SELECT $Partition.pf(TransactionDate) AS Partition, 
COUNT(*) AS [COUNT] FROM dbo.tbArchive
GROUP BY $partition.pf(TransactionDate)
ORDER BY Partition ;
 
--資料尚未從 TransactionHistory 轉移到 TransactionHistoryArchive
SELECT * FROM tbArchive WHERE TransactionDate > '20130901'


USE [dbPart]
GO
--索引沒有照 Partition 切割，就無法 switch partition	
--若要建 UNIQUE INDEX，則必須包含切割鍵值。
--否則索引散在不同的資料分割配置無法維護唯一性
/*
訊息 1908，層級 16，狀態 1，行 1
資料行 'TransactionDate' 是索引 'ix_tb_ProductID' 的資料分割資料行。唯一索引的資料分割資料行必須是索引鍵的子集。
*/
CREATE UNIQUE INDEX ix_tb_ProductID ON [dbo].[tb]
(
	[ProductID] ASC
)ON [ps]([TransactionDate])

--OK
CREATE UNIQUE INDEX ix_tb_ProductID ON [dbo].[tb]
(
	[ProductID],[TransactionDate]
) ON [ps]([TransactionDate])


GO
--重新下一個轉換的過程
--設定下一個可用的 filegroup 
--也就是為 Partition Scheme 準備多一個空間
ALTER PARTITION SCHEME ps2 NEXT USED [PRIMARY]

--ALTER PARTITION FUNCTION pf2() SPLIT RANGE('20131101')

 --讓歸檔多一個可以存放將轉移過來資料的空間
ALTER PARTITION FUNCTION pf2() SPLIT RANGE('20131001')

--將 09/01/2013 <= partition2 < 10/01/2013 轉移到tbArchive 
ALTER TABLE tb SWITCH PARTITION 2 TO tbArchive PARTITION 2

--檢視移轉後的結果
SELECT * FROM tbArchive WHERE TransactionDate >= '20130901'

--將tb原空下來的 Partition 合併，也就是將邊界往後移一個月 
ALTER PARTITION FUNCTION pf() MERGE RANGE('20130901')

--將轉移過來 Archive 小於 09/01/2013 的資料併入整個 Archive 資料表中
ALTER PARTITION FUNCTION pf2() MERGE RANGE('20130901')

--在來源資料表新增一個 Partition 放新的月份紀錄
ALTER PARTITION FUNCTION pf() SPLIT RANGE('20140901')

ALTER PARTITION FUNCTION pf2() SPLIT RANGE('20131101')

