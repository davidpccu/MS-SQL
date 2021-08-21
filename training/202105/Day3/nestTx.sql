use tempdb
create or alter proc sp @i int
as
	begin tran
		select 'outer',@@TRANCOUNT
		exec sp2 @i
		select 'outer',@@TRANCOUNT
	commit tran
go
create or alter proc sp2 @i int
as
	begin tran
	select 'inner',@@TRANCOUNT
	if @i>0
	begin
		commit
		select 'inner',@@TRANCOUNT
	end
	else
	begin
		rollback
		select 'inner',@@TRANCOUNT
	end
go

exec sp 0