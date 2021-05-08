select len('aい'),DATALENGTH('aい'),DATALENGTH(N'aい')
declare @c varchar(2)='aい',@c2 nchar(2)=N'aい'
select len(@c),@c,@c2,convert(varbinary(10),@c),convert(varbinary(20),'い')
go

declare @a char(10)='a',@a2 varchar(10)='a'
select DATALENGTH(@a),DATALENGTH(@a2)
if @a=@a2
begin
	print 'true'
end
else
begin
	print 'false'
end


