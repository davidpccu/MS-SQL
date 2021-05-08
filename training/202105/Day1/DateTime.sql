use tempdb
declare @d date='00010101',@d2 datetime=getdate(),@d3 datetime2(0)=getdate(),@t time(7)=sysdatetime()
select @d,DATALENGTH(@d),@d2,DATALENGTH(@d2),@d3,DATALENGTH(@d3),@t,DATALENGTH(@t)
go
select getdate()
go 20

declare @d datetime='20210508 23:59:59.998'
select @d
set @d='17521231' -- 17550101
select @d

go
declare @d datetime2(7)='00010101 23:59:59.12345678'
select @d
go
select sysdatetime()
go 20







