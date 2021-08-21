USE [AdventureWorksDW2012]
GO

/****** Object:  StoredProcedure [dbo].[sp]    Script Date: 2021/8/21 �U�� 04:18:30 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER   proc [dbo].[sp] @unitCost real
as
	declare @i real
	set @i=@unitCost	-- �Ĥ@�ؤ覡
	select * from FactProductInventory 
	where UnitCost < @i
	--option(optimize for(@unitCost=100)) -- page8-12 �ĤG�ؤ覡
GO

ALTER   proc [dbo].[sp] @unitCost real
--with recompile
as
	select * from FactProductInventory 
	where UnitCost < @unitCost
go

-- ����p�e
exec sp 0.1-- with recompile
exec sp 1

go
dbcc freeproccache -- �M������p�e