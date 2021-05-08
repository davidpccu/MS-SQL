declare @i numeric(38,0)=12345678901234567890123456789012345678
select @i,DATALENGTH(@i)
go
declare @i float=0,@j float=0.1
while @i<1
begin
	set @i+=@j
	print @i
end
