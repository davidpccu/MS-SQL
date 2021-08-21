use tempdb
go
create or alter proc sp @c1 int=0,@c2 int=2,@c3 int output
as
	set @c3=@c1+@c2
	return 1234
go
declare @c1 int=1,@c2 int=2,@c3 int,@return int
exec @return=sp default,@c2,@c3 output
select @return,@c3
go
declare @c1 int=1,@c2 int=2,@c3 int,@return int
exec @return=sp @c3=@c3 output,@c2=@c2
select @return,@c3

