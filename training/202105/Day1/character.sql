select len('a��'),DATALENGTH('a��'),DATALENGTH(N'a��')
declare @c varchar(2)='a��',@c2 nchar(2)=N'a��'
select len(@c),@c,@c2,convert(varbinary(10),@c),convert(varbinary(20),'��')
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


